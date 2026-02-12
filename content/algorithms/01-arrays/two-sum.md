# 两数之和 (Two Sum)

**难度：** ⭐ | **频率：** 🔥🔥🔥🔥🔥 | **标签：** 数组、哈希表

## 📌 题目描述

给定一个整数数组 `nums` 和一个整数目标值 `target`，请你在该数组中找出和为目标值 `target` 的那两个整数，并返回它们的数组下标。

你可以假设每种输入只会对应一个答案。但是，数组中同一个元素在答案里不能重复出现。

### 示例
```
输入：nums = [2,7,11,15], target = 9
输出：[0,1]
解释：因为 nums[0] + nums[1] == 9 ，返回 [0, 1] 。
```

```
输入：nums = [3,2,4], target = 6
输出：[1,2]
```

```
输入：nums = [3,3], target = 6
输出：[0,1]
```

### 约束条件
- `2 <= nums.length <= 10^4`
- `-10^9 <= nums[i] <= 10^9`
- `-10^9 <= target <= 10^9`

---

## 💡 解题思路

### 思路一：暴力枚举 (Brute Force)

**核心思想：** 双重循环遍历所有可能的组合

```mermaid
graph LR
    A[开始] --> B[外层循环 i]
    B --> C[内层循环 j=i+1]
    C --> D{nums[i]+nums[j]==target?}
    D -->|是| E[返回结果]
    D -->|否| C
    C --> F[继续]
    F --> D
```

**算法步骤：**
1. 外层循环遍历 `i` 从 0 到 n-2
2. 内层循环遍历 `j` 从 i+1 到 n-1
3. 判断 `nums[i] + nums[j] == target`
4. 满足条件则返回 `[i, j]`

**复杂度分析：**
- 时间复杂度：O(n²)
- 空间复杂度：O(1)

---

### ✅ 思路二：哈希表 (Hash Table) 【推荐】

**核心思想：** 用空间换时间，用哈希表存储「数值 → 索引」的映射

```mermaid
graph LR
    A[遍历数组] --> B{target-nums[i]在哈希表?}
    B -->|是| C[找到答案]
    B -->|否| D[将nums[i]存入哈希表]
    D --> A
```

**算法步骤：**
1. 创建一个空哈希表 `map` (数值 → 索引)
2. 遍历数组，对于每个元素 `nums[i]`：
   - 计算 `complement = target - nums[i]`
   - 如果 `complement` 在 `map` 中，返回 `[map[complement], i]`
   - 否则，将 `nums[i]` 存入 `map`
3. 如果遍历完没找到，返回空（题目保证有解）

**为什么有效？**
- 哈希表查找平均 O(1) 时间
- 只需一次遍历即可判断是否找到配对

**复杂度分析：**
- 时间复杂度：O(n)
- 空间复杂度：O(n)

---

## 💻 代码实现

### Python
```python
def twoSum(nums, target):
    """
    哈希表解法
    Time: O(n)
    Space: O(n)
    """
    # 哈希表存储 {数值: 索引}
    num_map = {}

    for i, num in enumerate(nums):
        complement = target - num
        if complement in num_map:
            return [num_map[complement], i]
        num_map[num] = i

    return []  # 题目保证有解，这里不会执行

# 测试
print(twoSum([2,7,11,15], 9))  # [0, 1]
print(twoSum([3,2,4], 6))      # [1, 2]
print(twoSum([3,3], 6))        # [0, 1]
```

### JavaScript
```javascript
/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
function twoSum(nums, target) {
    const map = new Map();

    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        if (map.has(complement)) {
            return [map.get(complement), i];
        }
        map.set(nums[i], i);
    }

    return [];
}

// 测试
console.log(twoSum([2,7,11,15], 9)); // [0, 1]
console.log(twoSum([3,2,4], 6));     // [1, 2]
console.log(twoSum([3,3], 6));       // [0, 1]
```

### Java
```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map = new HashMap<>();

        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            if (map.containsKey(complement)) {
                return new int[] { map.get(complement), i };
            }
            map.put(nums[i], i);
        }

        return new int[] {};
    }
}
```

### Go
```go
func twoSum(nums []int, target int) []int {
    m := make(map[int]int)

    for i, num := range nums {
        complement := target - num
        if j, ok := m[complement]; ok {
            return []int{j, i}
        }
        m[num] = i
    }

    return nil
}
```

---

## 🎯 面试要点

### 问答准备
**Q: 为什么用哈希表？**
A: 暴力解法需要O(n²)时间，哈希表可以将查找从O(n)降到O(1)，整体复杂度降至O(n)。

**Q: 有没有办法优化空间复杂度？**
A: 如果数组有序，可以用双指针法将空间优化到O(1)，但需要先排序O(n log n)。

**Q: 如果有多个解怎么办？**
A: 可以用列表存储所有解，或者返回第一个找到的解（需要和面试官确认需求）。

**Q: 如果没有找到解？**
A: 返回空数组或特殊值（如[-1, -1]），视具体要求而定。

---

## 🔄 相关题目

| 题目 | 难度 | 关联点 |
|------|------|--------|
| 三数之和 | 中 | 哈希表 + 双指针 |
| 四数之和 | 中 | 哈希表 + 双指针 + 剪枝 |
| 两数之和 II | 简单 | 有序数组，双指针 |

---

## 📊 进阶思考

### 变体1：返回数值而非索引
```python
def twoSumValues(nums, target):
    seen = set()
    for num in nums:
        complement = target - num
        if complement in seen:
            return [complement, num]
        seen.add(num)
    return []
```

### 变体2：找到所有可能的两数之和组合
```python
def twoSumAllPairs(nums, target):
    result = []
    seen = {}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in seen:
            for j in seen[complement]:
                result.append([j, i])
        if num not in seen:
            seen[num] = []
        seen[num].append(i)
    return result
```

### 变体3：数组有重复元素的处理
```python
def twoSumWithDuplicates(nums, target):
    # 需要返回所有不重复的组合
    num_count = {}
    for num in nums:
        num_count[num] = num_count.get(num, 0) + 1

    result = set()
    for num in num_count:
        complement = target - num
        if complement in num_count:
            if complement == num and num_count[num] >= 2:
                result.add(tuple(sorted([num, complement])))
            elif complement != num:
                result.add(tuple(sorted([num, complement])))

    return [list(pair) for pair in result]
```

---

## 💡 面试技巧

1. **先说暴力解法** - 展示你能解决问题
2. **再提优化思路** - 展示分析和优化能力
3. **主动分析复杂度** - 展示基本功
4. **讨论边界情况** - 展示思维严谨性
5. **如果时间充足，主动提及相关题目** - 展示知识广度

---

**掌握这道题，你就掌握了：**
✅ 哈希表的基本应用
✅ 用空间换时间的经典思想
✅ 面试时的解题思路框架
