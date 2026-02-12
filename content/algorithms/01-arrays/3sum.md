# 三数之和 (3Sum)

**难度：** ⭐⭐⭐ | **频率：** 🔥🔥🔥🔥🔥 | **标签：** 数组、双指针、排序

## 📌 题目描述

给你一个整数数组 `nums`，判断是否存在三元组 `[nums[i], nums[j], nums[k]]` 满足 `i != j`、`i != k` 且 `j != k`，同时还满足 `nums[i] + nums[j] + nums[k] == 0`。

请你返回所有和为 0 且不重复的三元组。

### 示例
```
输入：nums = [-1,0,1,2,-1,-4]
输出：[[-1,-1,2],[-1,0,1]]
解释：
nums[0] + nums[1] + nums[2] = (-1) + 0 + 1 = 0
nums[1] + nums[2] + nums[4] = 0 + 1 + (-1) = 0
nums[0] + nums[3] + nums[4] = (-1) + 2 + (-1) = 0
不同的三元组是 [-1,0,1] 和 [-1,-1,2]
注意，输出的顺序和三元组的顺序并不重要
```

```
输入：nums = [0,1,1]
输出：[]
解释：唯一可能的三元组和不为 0
```

```
输入：nums = [0,0,0]
输出：[[0,0,0]]
```

### 约束条件
- `3 <= nums.length <= 3000`
- `-10^5 <= nums[i] <= 10^5`

---

## 💡 解题思路

### 核心洞察

三数之和 a + b + c = 0 可以转化为：找 a、b，使得 a + b = -c

这与两数之和类似，但需要处理去重问题。

---

### 思路一：暴力枚举 (Brute Force)

**算法步骤：**
1. 三重循环遍历所有可能的三元组
2. 判断和是否为0
3. 使用Set去重

**复杂度分析：**
- 时间复杂度：O(n³)
- 空间复杂度：O(n) 用于去重

❌ 会超时，不推荐

---

### ✅ 思路二：排序 + 双指针 【推荐】

**核心思想：**
1. 先排序数组（去重关键）
2. 固定第一个数，用双指针找另外两个数
3. 利用排序特性跳过重复元素

**算法流程图：**

```
排序后: [-4, -1, -1, 0, 1, 2]
         ↑
         i (固定)
            ↑        ↑
            left    right (双指针移动)
```

**算法步骤：**

```python
def threeSum(nums):
    nums.sort()  # 1. 排序
    result = []

    for i in range(len(nums) - 2):  # 2. 固定第一个数
        # 跳过重复元素
        if i > 0 and nums[i] == nums[i-1]:
            continue

        # 优化：如果最小的三个数都大于0，不可能有解
        if nums[i] > 0:
            break

        left, right = i + 1, len(nums) - 1

        while left < right:  # 3. 双指针查找
            total = nums[i] + nums[left] + nums[right]

            if total == 0:
                result.append([nums[i], nums[left], nums[right]])

                # 跳过重复元素
                while left < right and nums[left] == nums[left + 1]:
                    left += 1
                while left < right and nums[right] == nums[right - 1]:
                    right -= 1

                left += 1
                right -= 1

            elif total < 0:
                left += 1  # 需要更大的数
            else:
                right -= 1  # 需要更小的数

    return result
```

**关键点解析：**

| 技巧 | 说明 |
|------|------|
| 先排序 | 为双指针和去重提供基础 |
| `nums[i] == nums[i-1]` | 跳过第一个数的重复 |
| 内层while跳过重复 | 跳过第二、三个数的重复 |
| `nums[i] > 0` 则break | 优化：最小数都>0则无解 |
| `total < 0` 则left++ | 排序后，小的在左边 |

**复杂度分析：**
- 时间复杂度：O(n²) - 排序O(n log n) + 双重循环O(n²)
- 空间复杂度：O(1) - 不考虑结果存储空间

---

## 💻 代码实现

### Python
```python
def threeSum(nums):
    """
    排序 + 双指针
    Time: O(n²)
    Space: O(1)
    """
    nums.sort()
    result = []
    n = len(nums)

    for i in range(n - 2):
        # 跳过重复元素
        if i > 0 and nums[i] == nums[i - 1]:
            continue

        # 优化：最小数大于0，不可能有解
        if nums[i] > 0:
            break

        left, right = i + 1, n - 1

        while left < right:
            total = nums[i] + nums[left] + nums[right]

            if total == 0:
                result.append([nums[i], nums[left], nums[right]])

                # 跳过left的重复元素
                while left < right and nums[left] == nums[left + 1]:
                    left += 1
                # 跳过right的重复元素
                while left < right and nums[right] == nums[right - 1]:
                    right -= 1

                left += 1
                right -= 1

            elif total < 0:
                left += 1
            else:
                right -= 1

    return result

# 测试
print(threeSum([-1,0,1,2,-1,-4]))  # [[-1,-1,2],[-1,0,1]]
print(threeSum([0,1,1]))           # []
print(threeSum([0,0,0]))           # [[0,0,0]]
```

### JavaScript
```javascript
/**
 * @param {number[]} nums
 * @return {number[][]}
 */
function threeSum(nums) {
    nums.sort((a, b) => a - b);
    const result = [];
    const n = nums.length;

    for (let i = 0; i < n - 2; i++) {
        // 跳过重复元素
        if (i > 0 && nums[i] === nums[i - 1]) continue;

        // 优化：最小数大于0，不可能有解
        if (nums[i] > 0) break;

        let left = i + 1;
        let right = n - 1;

        while (left < right) {
            const total = nums[i] + nums[left] + nums[right];

            if (total === 0) {
                result.push([nums[i], nums[left], nums[right]]);

                // 跳过重复元素
                while (left < right && nums[left] === nums[left + 1]) left++;
                while (left < right && nums[right] === nums[right - 1]) right--;

                left++;
                right--;
            } else if (total < 0) {
                left++;
            } else {
                right--;
            }
        }
    }

    return result;
}
```

### Java
```java
class Solution {
    public List<List<Integer>> threeSum(int[] nums) {
        Arrays.sort(nums);
        List<List<Integer>> result = new ArrayList<>();
        int n = nums.length;

        for (int i = 0; i < n - 2; i++) {
            // 跳过重复元素
            if (i > 0 && nums[i] == nums[i - 1]) continue;

            // 优化：最小数大于0，不可能有解
            if (nums[i] > 0) break;

            int left = i + 1;
            int right = n - 1;

            while (left < right) {
                int total = nums[i] + nums[left] + nums[right];

                if (total == 0) {
                    result.add(Arrays.asList(nums[i], nums[left], nums[right]));

                    // 跳过重复元素
                    while (left < right && nums[left] == nums[left + 1]) left++;
                    while (left < right && nums[right] == nums[right - 1]) right--;

                    left++;
                    right--;
                } else if (total < 0) {
                    left++;
                } else {
                    right--;
                }
            }
        }

        return result;
    }
}
```

---

## 🎯 面试要点

### 常见问题

**Q: 为什么要先排序？**
A:
1. 排序后可以利用双指针，将O(n²)降到O(n)
2. 排序后方便去重（相同元素相邻）
3. 可以进行剪枝优化（如最小数>0则break）

**Q: 如何确保不重复？**
A: 三层去重
- 外层：`if i > 0 and nums[i] == nums[i-1]: continue`
- 内层left：找到解后跳过所有相同的left
- 内层right：找到解后跳过所有相同的right

**Q: 时间复杂度为什么是O(n²)而不是O(n³)？**
A: 排序O(n log n)，外层循环O(n)，内层双指针O(n)，所以是O(n²)。

**Q: 如果不求和为0，而是求和为target怎么办？**
A: 将 `total == 0` 改为 `total == target`，其他逻辑不变。

---

## 🔄 相关题目

| 题目 | 难度 | 关联点 |
|------|------|--------|
| 两数之和 | 简单 | 双指针基础 |
| 四数之和 | 中 | 多层双指针 + 剪枝 |
| 最接近的三数之和 | 中 | 双指针变种 |

---

## 💡 面试技巧

1. **先分析暴力解法** - 展示思考过程
2. **指出优化方向** - 去重是难点，排序可以帮助
3. **画图说明双指针** - 视觉化更有说服力
4. **讨论边界情况** - 全0、全正、全负等
5. **主动提变体** - 如求最接近target的三数之和

---

**掌握这道题，你就掌握了：**
✅ 排序 + 双指针的经典组合
✅ 数组去重的核心技巧
✅ 双层循环中的剪枝优化
