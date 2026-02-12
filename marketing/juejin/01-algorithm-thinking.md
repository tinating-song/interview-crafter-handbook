# 掘金/知乎技术文章 - 第1篇

## 标题
**LeetCode刷题两年总结：高频50题背后的算法思想**

## 文章分类
- 前端
- 后端
- 算法

---

## 正文

刷了两年的LeetCode，从最初的刷题困难户到现在的游刃有余，我发现面试真正爱考的题目其实就那么50道。

更重要的是，这50道题背后蕴含了几个核心算法思想，掌握这些思想，一通百通。

今天分享我的刷题经验，希望对大家有帮助。

---

## 📊 高频50题的分布统计

根据我在各大厂面试中的经验，这50题的分布大致如下：

| 类别 | 题目数量 | 面试频率 |
|------|---------|---------|
| 数组双指针 | 10 | ⭐⭐⭐⭐⭐ |
| 字符串滑动窗口 | 8 | ⭐⭐⭐⭐⭐ |
| 链表 | 8 | ⭐⭐⭐⭐ |
| 二分查找 | 5 | ⭐⭐⭐⭐ |
| 动态规划 | 10 | ⭐⭐⭐⭐ |
| 回溯算法 | 5 | ⭐⭐⭐ |
| BFS/DFS | 4 | ⭐⭐⭐⭐ |

---

## 💡 核心算法思想一：双指针

双指针是最常用也是最容易被忽视的技巧。

### 经典题目：三数之和

题目：给定数组，找出所有和为0的三元组。

暴力解法需要O(n³)，但用双指针可以优化到O(n²)：

```python
def threeSum(nums):
    nums.sort()
    result = []

    for i in range(len(nums) - 2):
        # 跳过重复元素
        if i > 0 and nums[i] == nums[i - 1]:
            continue

        left, right = i + 1, len(nums) - 1

        while left < right:
            total = nums[i] + nums[left] + nums[right]

            if total == 0:
                result.append([nums[i], nums[left], nums[right]])
                # 跳过重复
                while left < right and nums[left] == nums[left + 1]:
                    left += 1
                while left < right and nums[right] == nums[right - 1]:
                    right -= 1
                left += 1
                right -= 1
            elif total < 0:
                left += 1
            else:
                right -= 1

    return result
```

**关键点**：
1. 先排序
2. 固定一个数，用双指针找另外两个
3. 利用排序特性跳过重复元素

---

## 💡 核心算法思想二：滑动窗口

滑动窗口是处理子数组/子串问题的利器。

### 经典题目：无重复字符最长子串

题目：找出不含重复字符的最长子串。

```python
def lengthOfLongestSubstring(s):
    char_index = {}
    left = 0
    max_len = 0

    for right, char in enumerate(s):
        # 遇到重复字符且在窗口内
        if char in char_index and char_index[char] >= left:
            left = char_index[char] + 1

        char_index[char] = right
        max_len = max(max_len, right - left + 1)

    return max_len
```

**滑动窗口模板**：
```python
def slidingWindow(s):
    left = 0
    window = {}

    for right in range(len(s)):
        # 扩大窗口
        window.add(s[right])

        # 判断是否需要收缩
        while need_shrink():
            window.remove(s[left])
            left += 1

        # 更新答案
        update_result()
```

---

## 💡 核心算法思想三：哈希表

哈希表是空间换时间的典型应用。

### 经典题目：两数之和

题目：找出数组中和为target的两个数。

```python
def twoSum(nums, target):
    num_map = {}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in num_map:
            return [num_map[complement], i]
        num_map[num] = i
    return []
```

暴力解法O(n²)，用哈希表可以优化到O(n)。

---

## 📝 我整理的面试手册

刷题过程中，我整理了一份**面试通关手册**，包含：

1. **高频50题精讲** - 每题都有思路、代码、复杂度分析
2. **4种语言代码** - Python/JavaScript/Java/Go
3. **面试要点** - 面试官可能追问的问题
4. **解题思路图** - 可视化理解算法

### 免费预览

GitHub上有部分内容免费预览：
- 两数之和
- 三数之和
- 无重复字符最长子串
- STAR法则（行为面试）
- 短链接系统（系统设计）

👉 搜索 **interview-crafter-handbook**

### 完整版

完整版包含全部50题 + 系统设计 + 行为面试 + 简历优化。

定价 ¥29，限时优惠中。

---

## 🎯 刷题建议

1. **按主题刷** - 同一类型的题一起刷，总结模板
2. **一题多解** - 思考多种解法，比较优劣
3. **定期回顾** - 做过的题二刷、三刷
4. **模拟面试** - 练习边写边说，训练表达能力

---

**最后，如果这份手册对你有帮助，给个⭐支持一下！**

---

## 文末引导

```
┌─────────────────────────────────┐
│   面试通关手册                  │
│   💎 高频算法50题精讲            │
│   🏗️ 系统设计10+案例             │
│   💬 行为面试STAR法则            │
│   📝 简历优化指南                │
├─────────────────────────────────┤
│   📄 免费预览：GitHub搜索        │
│            interview-crafter     │
│   💎 完整版：¥29（限时优惠）      │
└─────────────────────────────────┘
```

---

## 标签
面试、算法、LeetCode、前端、后端、算法与数据结构、刷题、程序员
