# 掘金/知乎技术文章 - 第2篇

## 标题
**系统设计面试：手把手教你设计短链接服务（TinyURL）**

## 文章分类
- 后端
- 架构
- 系统设计

---

## 前言

短链接系统是系统设计面试中最常考的基础题目之一。

看似简单，但其实涉及到很多核心知识点：
- URL生成算法
- 数据库设计
- 缓存策略
- 读写分离
- 分布式ID生成

今天我以TinyURL为例，从需求分析到落地实现，完整梳理一遍。

---

## 📌 需求分析

### 功能需求
1. 输入长链接，返回短链接
2. 访问短链接时重定向到原始长链接
3. 可选：自定义短链后缀
4. 可选：设置过期时间

### 非功能需求
- 高可用：99.9%
- 低延迟：生成和重定向 < 100ms
- 可扩展：支持百万QPS

### 容量估算
假设：
- 写 QPS：1000/s
- 读 QPS：10000/s（读写比1:10）
- 存储：10亿条记录，每条500字节
- 总存储：500GB

---

## 🔑 核心设计：短链接生成算法

### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| 随机生成 | 实现简单 | 需要检查冲突 |
| MD5哈希 | 确定性 | 需处理冲突 |
| **Base62转换** | 无冲突、可逆 | 需要ID |

### 推荐：Base62转换

核心思想：将数据库自增ID转换为Base62编码

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

# 示例
# ID: 12345678 → 短码: "x7zK3"
```

**为什么不用Base64？**
- Base64包含 `+`、`/`、`=` 等特殊字符
- 这些字符在URL中需要编码
- Base62只用数字和字母，URL友好

---

## 🏗️ 系统架构

```
用户请求
  ↓
CDN（静态资源）
  ↓
Load Balancer
  ↓
API服务器
  ↓
  ├→ 缩写服务（写） → DB → Redis
  └→ 重定向服务（读） → Redis → DB（miss时）
```

### 数据库设计

```sql
CREATE TABLE url_mapping (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    short_code VARCHAR(10) UNIQUE NOT NULL,
    long_url TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    click_count INT DEFAULT 0,
    INDEX idx_short_code (short_code)
);
```

### 缓存策略

```
Key: "short:abc123"
Value: {
    "long_url": "https://...",
    "created_at": "2025-01-15T10:00:00Z",
    "click_count": 1234
}
TTL: 24小时
```

---

## 📈 扩展性设计

### 读写分离

```
写请求 → 主库
读请求 → 从库（多个）
```

### 分库分表

按ID取模分片：
```python
def get_shard(id):
    return id % 16  # 分16个库
```

### 缓存优化

- LRU淘汰策略
- 热点数据预热
- 缓存穿透防护（布隆过滤器）

---

## 🔒 安全考虑

| 攻击类型 | 防护措施 |
|---------|---------|
| 垃圾短链 | 限流、用户注册 |
| 钓鱼攻击 | 安全浏览页提示 |
| DDoS | CDN、限流 |
| SQL注入 | 参数校验、预处理 |

---

## 🎯 面试高频问题

**Q: 为什么选择Base62？**
A: URL友好、无冲突、可逆、高效

**Q: 如何处理自定义短链冲突？**
A: 先检查是否占用，被占用则返回错误

**Q: 重定向用301还是302？**
A: 默认302（灵活），确定不变的链接用301

**Q: 如果短链被恶意使用？**
A: 举报机制、黑名单系统、限制单用户生成数

---

## 📚 延伸阅读

我整理了一份**面试通关手册**，包含：

### 系统设计部分
- 短链接系统（TinyURL）
- 微博系统（Twitter）
- 聊天系统（WhatsApp/微信）
- 推荐系统
- 限流系统
- ...共10+个案例

每个案例都有：
- ✅ 需求分析
- ✅ 架构设计图
- ✅ 技术选型对比
- ✅ 面试问答要点

### 免费预览
GitHub上有短链接系统完整案例！

👉 搜索 **interview-crafter-handbook**

### 完整版
全部10+系统设计案例 + 算法题解 + 行为面试 + 简历优化

定价 **¥29**，限时优惠中

---

**如果这篇文章对你有帮助，给个⭐支持一下！**

---

## 文末引导

```
┌─────────────────────────────────┐
│   面试通关手册                  │
│   💎 算法50题精讲               │
│   🏗️ 系统设计10+案例            │
│   💬 行为面试STAR法则            │
│                                │
│   GitHub: interview-crafter     │
│   💎 完整版 ¥29（限时优惠）      │
└─────────────────────────────────┘
```

---

## 标签
系统设计、架构、后端、面试、TinyURL、短链接、分布式系统
