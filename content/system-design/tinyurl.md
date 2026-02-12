# 短链接系统设计 (TinyURL/Bitly)

**难度：** ⭐⭐⭐ | **频率：** 🔥🔥🔥🔥 | **类型：** 系统设计基础题

## 📌 需求分析

### 功能需求
1. **URL缩短**：输入长链接，返回短链接
   - 示例：`https://www.example.com/very/long/path` → `https://tinyurl.com/abc123`

2. **URL重定向**：访问短链接时重定向到原始长链接

3. **自定义短链**：用户可指定短链后缀（可选）

4. **过期时间**：短链接可设置有效期（可选）

### 非功能需求
- **高可用**：99.9% 可用性
- **低延迟**：生成和重定向延迟 < 100ms
- **可扩展**：支持每秒数百万请求

### 假设与约束
- QPS（每秒查询数）：写 1000/s，读 10000/s（读写比 1:10）
- 数据量：10亿条记录，每条500字节
- 存储需求：500GB
- 保留期：链接至少保存2年

---

## 🏗️ 系统架构

### 整体架构图

```
                    用户请求
                       ↓
                  ┌─────────┐
                  │  DNS   │
                  └─────────┘
                       ↓
                  ┌─────────┐
                  │  CDN   │ ← 静态资源
                  └─────────┘
                       ↓
              ┌─────────────────┐
              │   Load Balancer │
              └─────────────────┘
                       ↓
          ┌────────────┴────────────┐
          ↓                         ↓
    ┌──────────┐              ┌──────────┐
    │ API 服务器 │              │ API 服务器 │
    └──────────┘              └──────────┘
          ↓                         ↓
    ┌─────────────────────────────────┐
    │            服务层                │
    │  ┌──────┐  ┌──────┐  ┌──────┐  │
    │  │缩写服务│  │重定向服务│ │元数据│  │
    │  └──────┘  └──────┘  └──────┘  │
    └─────────────────────────────────┘
          ↓         ↓         ↓
    ┌─────────────────────────────────┐
    │            数据层                │
    │  ┌──────┐    ┌──────┐          │
    │  │Redis │ ←→ │数据库 │          │
    │  └──────┘    └──────┘          │
    │      ↓                          │
    │  ┌────────────────┐            │
    │  │   分布式缓存    │            │
    │  └────────────────┘            │
    └─────────────────────────────────┘
```

---

## 🔑 核心设计

### 1. 短链接生成算法

#### 方案一：随机生成
```python
import random
import string

def generate_short_code(length=7):
    chars = string.ascii_letters + string.digits  # a-zA-Z0-9
    return ''.join(random.choice(chars) for _ in range(length))

# abc123G, xYz9Qm2 等
```

**优点**：实现简单
**缺点**：需要检查冲突

#### 方案二：哈希函数
```python
import hashlib

def generate_short_code(url):
    hash_obj = hashlib.md5(url.encode())
    hex_digest = hash_obj.hexdigest()
    return hex_digest[:7]  # 取前7位
```

**优点**：确定性，相同URL生成相同短码
**缺点**：可能冲突，需要处理

#### ✅ 方案三：Base62转换 【推荐】

**核心思想**：将数据库自增ID转换为Base62编码

```python
ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

def base62_encode(num):
    if num == 0:
        return ALPHABET[0]
    arr = []
    base = len(ALPHABET)
    while num:
        num, rem = divmod(num, base)
        arr.append(ALPHABET[rem])
    arr.reverse()
    return ''.join(arr)

# ID 1 → "1"
# ID 12345 → "d7C"
# ID 1000000 → "4c92"
```

**优点**：
- 无冲突：ID唯一保证短码唯一
- 可逆：可以解码还原ID
- 高效：O(1)时间复杂度

**实现流程**：
```
长URL → 存入DB → 获得ID → Base62编码 → 短码
https://example.com/long → ID: 12345678 → "x7zK3"
```

---

### 2. 数据库设计

#### 关系型数据库方案（MySQL）

```sql
CREATE TABLE url_mapping (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    short_code VARCHAR(10) UNIQUE NOT NULL,
    long_url TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    click_count INT DEFAULT 0,
    INDEX idx_short_code (short_code),
    INDEX idx_expires_at (expires_at)
);
```

**字段说明**：
- `id`：主键，用于Base62转换
- `short_code`：短链接后缀，建立索引
- `long_url`：原始长链接
- `expires_at`：过期时间，NULL表示永久
- `click_count`：访问统计

#### 数据量估算
- 单条记录：~500字节
- 10亿记录：500GB
- 使用分库分表：按ID哈希分16个库

---

### 3. 缓存策略

#### Redis缓存设计

```
Key: "short:abc123"
Value: {
    "long_url": "https://long.url.com/path",
    "created_at": "2025-01-15T10:00:00Z",
    "expires_at": "2025-02-15T10:00:00Z",
    "click_count": 1234
}
TTL: 24小时
```

**缓存策略**：
- **写操作**：先写DB，再更新缓存
- **读操作**：先读缓存，miss则读DB并更新缓存
- **过期时间**：24小时，LRU淘汰
- **缓存预热**：热点短链接提前加载

---

### 4. 重定向流程

#### 重定向类型选择

| 类型 | 说明 | 优点 | 缺点 |
|------|------|------|------|
| 301永久重定向 | 浏览器缓存 | 减少服务器压力 | 修改困难 |
| 302临时重定向 | 每次都查询 | 灵活 | 服务器压力大 |

**推荐**：默认302，对于确定不变的链接使用301

#### 重定向流程
```python
def redirect(short_code):
    # 1. 检查缓存
    cached = redis.get(f"short:{short_code}")
    if cached:
        return Redirect(cached['long_url'])

    # 2. 查询数据库
    record = db.query("SELECT long_url FROM url_mapping WHERE short_code = ?", short_code)
    if not record:
        raise NotFound()

    # 3. 更新缓存
    redis.set(f"short:{short_code}", record, ex=86400)

    # 4. 异步更新点击统计
    async_update_click_count(short_code)

    # 5. 返回重定向
    return Redirect(record['long_url'])
```

---

## 📈 扩展性设计

### 读写分离架构

```
                  写请求              读请求
                   ↓                   ↓
    ┌──────────────────────────────────────────┐
    │              主数据库                    │
    └───────────────────┬──────────────────────┘
                        │ 复制
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
    ┌───────┐       ┌───────┐       ┌───────┐
    │从库1  │       │从库2  │       │从库3  │
    └───────┘       └───────┘       └───────┘
```

### 分库分表策略

**按ID取模分片**：
```python
def get_shard(id):
    return id % 16  # 分16个库
```

**问题**：扩容时需要大量数据迁移

**改进方案**：一致性哈希
- 减少扩容时的数据迁移
- 增加节点时只需迁移1/N的数据

---

## 🔒 安全考虑

### 潜在攻击与防护

| 攻击类型 | 描述 | 防护措施 |
|---------|------|----------|
| 垃圾短链 | 恶意用户大量生成 | 限流、用户注册 |
| 钓鱼攻击 | 短链隐藏真实URL | 安全浏览页提示 |
| DDoS攻击 | 大量请求短链接 | CDN、限流、黑名单 |
| 数据库注入 | 恶意URL注入 | 参数校验、预处理 |

### URL校验
```python
import re

def is_valid_url(url):
    pattern = re.compile(
        r'^https?://'  # http or https
        r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'  # domain
        r'localhost|'  # localhost
        r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'  # ip
        r'(?::\d+)?'  # optional port
        r'(?:/?|[/?]\S+)$', re.IGNORECASE)
    return pattern.match(url) is not None
```

---

## 📊 监控指标

### 关键指标
1. **QPS**：每秒请求数
2. **延迟**：P50、P99延迟
3. **缓存命中率**：目标 > 95%
4. **错误率**：4xx、5xx比例
5. **存储增长**：每日新增记录数

### 告警规则
- P99延迟 > 200ms
- 错误率 > 1%
- 缓存命中率 < 90%

---

## 🎯 面试问答要点

**Q: 为什么选择Base62而不是Base64？**
A:
- Base64包含 `+`、`/`、`=` 等特殊字符
- 这些字符在URL中需要编码，增加长度
- Base62只用数字和字母，URL友好

**Q: 如何处理自定义短链冲突？**
A:
1. 用户申请时先检查是否被占用
2. 如果占用，返回错误或建议其他后缀
3. 收费用户可优先选择

**Q: 如果短链接被恶意使用怎么办？**
A:
1. 实现举报机制
2. 建立黑名单系统
3. 限制单个用户的生成数量
4. 安全浏览页面显示目标URL

**Q: 如何实现用户访问统计？**
A:
1. 异步记录到分析数据库
2. 使用消息队列解耦
3. 提供可视化面板

---

## 🔄 扩展功能

1. **API服务**：提供RESTful API供第三方调用
2. **QR码生成**：自动生成二维码
3. **A/B测试**：同一短链按权重分发到不同URL
4. **链接有效性检测**：定时检测长链接是否可用
5. **地理位置统计**：记录访问者地区

---

**掌握这个系统设计，你就掌握了：**
✅ 短链接生成算法
✅ 缓存策略设计
✅ 读写分离架构
✅ 数据库分片思路
✅ 重定向优化
