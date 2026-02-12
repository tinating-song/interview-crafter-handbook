# 无重复字符最长子串

**难度：** ⭐⭐⭐ | **频率：** 🔥🔥🔥🔥🔥 | **标签：** 字符串、滑动窗口

## 📌 题目描述

给定一个字符串 `s`，请你找出其中不含有重复字符的**最长子串**的长度。

### 示例
```
输入: s = "abcabcbb"
输出: 3
解释: 因为无重复字符的最长子串是 "abc"，所以其长度为 3。
```

```
输入: s = "bbbbb"
输出: 1
解释: 因为无重复字符的最长子串是 "b"，所以其长度为 1。
```

```
输入: s = "pwwkew"
输出: 3
解释: 因为无重复字符的最长子串是 "wke"，所以其长度为 3。
     请注意，你的答案必须是子串的长度，"pwke" 是一个子序列，不是子串。
```

### 约束条件
- `0 <= s.length <= 5 * 10^4`
- `s` 由英文字母、数字、符号和空格组成

---

## 💡 解题思路

### 核心洞察

这道题的关键是维护一个**滑动窗口**，窗口内是没有重复字符的子串。

```
字符串: a b c a b c b b
窗口:   [a b c] a b c b b
         ↑     ↑
        left  right

遇到重复字符a，移动left
窗口:     [c a] b c b b
           ↑   ↑
          left right
```

---

### ✅ 思路：滑动窗口 + 哈希表 【推荐】

**核心思想**：
1. 使用`left`和`right`两个指针表示窗口边界
2. 用哈希表记录每个字符最后出现的位置
3. 当遇到重复字符时，移动`left`指针

**算法流程图：**

```
开始
  ↓
初始化 left=0, maxLen=0, charMap={}
  ↓
for right in range(len(s)):
  ↓
  s[right] 在 charMap 中?
    ├─ 是 → left = max(left, charMap[s[right]] + 1)
    └─ 否 → 继续
  ↓
  更新 charMap[s[right]] = right
  ↓
  更新 maxLen = max(maxLen, right - left + 1)
  ↓
返回 maxLen
```

**算法步骤：**

```python
def lengthOfLongestSubstring(s):
    char_index = {}  # 字符 → 最后出现的位置
    left = 0
    max_len = 0

    for right, char in enumerate(s):
        # 如果字符已出现过，且在当前窗口内
        if char in char_index and char_index[char] >= left:
            # 移动左边界到重复字符的下一个位置
            left = char_index[char] + 1

        # 更新字符的最新位置
        char_index[char] = right

        # 更新最大长度
        max_len = max(max_len, right - left + 1)

    return max_len
```

**关键点解析：**

| 步骤 | 说明 |
|------|------|
| `char_index[char] >= left` | 确保重复字符在当前窗口内 |
| `left = char_index[char] + 1` | 跳过重复字符 |
| `right - left + 1` | 当前窗口长度 |

**复杂度分析：**
- 时间复杂度：O(n) - 每个字符最多访问2次
- 空间复杂度：O(min(m, n)) - m为字符集大小

---

## 💻 代码实现

### Python
```python
def lengthOfLongestSubstring(s):
    """
    滑动窗口解法
    Time: O(n)
    Space: O(min(m, n))
    """
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

# 测试
print(lengthOfLongestSubstring("abcabcbb"))  # 3
print(lengthOfLongestSubstring("bbbbb"))     # 1
print(lengthOfLongestSubstring("pwwkew"))    # 3
print(lengthOfLongestSubstring(""))          # 0
```

### JavaScript
```javascript
/**
 * @param {string} s
 * @return {number}
 */
function lengthOfLongestSubstring(s) {
    const charIndex = new Map();
    let left = 0;
    let maxLen = 0;

    for (let right = 0; right < s.length; right++) {
        const char = s[right];

        // 遇到重复字符且在窗口内
        if (charIndex.has(char) && charIndex.get(char) >= left) {
            left = charIndex.get(char) + 1;
        }

        charIndex.set(char, right);
        maxLen = Math.max(maxLen, right - left + 1);
    }

    return maxLen;
}
```

### Java
```java
class Solution {
    public int lengthOfLongestSubstring(String s) {
        Map<Character, Integer> charIndex = new HashMap<>();
        int left = 0;
        int maxLen = 0;

        for (int right = 0; right < s.length(); right++) {
            char c = s.charAt(right);

            // 遇到重复字符且在窗口内
            if (charIndex.containsKey(c) && charIndex.get(c) >= left) {
                left = charIndex.get(c) + 1;
            }

            charIndex.put(c, right);
            maxLen = Math.max(maxLen, right - left + 1);
        }

        return maxLen;
    }
}
```

### Go
```go
func lengthOfLongestSubstring(s string) int {
    charIndex := make(map[rune]int)
    left := 0
    maxLen := 0

    for right, char := range s {
        if idx, ok := charIndex[char]; ok && idx >= left {
            left = idx + 1
        }
        charIndex[char] = right
        if right - left + 1 > maxLen {
            maxLen = right - left + 1
        }
    }

    return maxLen
}
```

---

## 🎯 面试要点

### 常见问题

**Q: 为什么用 `char_index[char] >= left` 判断？**
A: 因为字符可能重复出现在窗口之外，这种情况下不需要移动left。

```
示例: "a b c d e a f"
              ↑     ↑
             left  right
遇到a时，上次a在位置0，小于left=4，不需要移动
```

**Q: 如果返回最长子串而不是长度怎么办？**
A: 记录起始位置和结束位置，最后切片返回。

```python
def longestSubstring(s):
    char_index = {}
    left = 0
    max_len = 0
    start = 0  # 记录最长子串的起始位置

    for right, char in enumerate(s):
        if char in char_index and char_index[char] >= left:
            left = char_index[char] + 1

        char_index[char] = right

        if right - left + 1 > max_len:
            max_len = right - left + 1
            start = left

    return s[start:start + max_len]
```

**Q: 空间复杂度为什么不是O(n)?**
A: 字符集大小有限（ASCII是128，扩展ASCII是256），所以空间是O(min(m, n))。

**Q: 如果字符集很大（如Unicode）怎么办？**
A: 算法仍然有效，只是哈希表会更大。如果需要优化，可以用数组代替哈希表（如果字符集是连续的）。

---

## 🔄 相关题目

| 题目 | 难度 | 关联点 |
|------|------|--------|
| 最小覆盖子串 | 困难 | 滑动窗口 |
| 找到字符串中所有字母异位词 | 中 | 滑动窗口 |
| 字符串的排列 | 中 | 滑动窗口 |
| 至多包含K个不同字符的最长子串 | 中 | 滑动窗口+哈希表 |

---

## 💡 滑动窗口模板

```python
def slidingWindow(s):
    # 初始化窗口和状态
    left = 0
    window = {}

    for right in range(len(s)):
        # 扩大窗口
        window.add(s[right])

        # 判断是否需要收缩
        while need_shrink():
            # 收缩窗口
            window.remove(s[left])
            left += 1

        # 更新答案
        update_result()
```

**本题应用**：
- 扩大窗口：添加新字符
- 收缩条件：遇到重复字符
- 收缩操作：移动left到重复字符下一个位置

---

**掌握这道题，你就掌握了：**
✅ 滑动窗口的核心思想
✅ 哈希表在字符串处理中的应用
✅ 双指针的配合使用
✅ 窗口边界的控制技巧
