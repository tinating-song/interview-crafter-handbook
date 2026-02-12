#!/bin/bash

# 小红书自动发布脚本
# 账号：260577600

echo "======================================="
echo "    小红书自动发布工具"
echo "======================================="
echo ""

# 读取要发布的内容
POSTS=(
    "marketing/xiaohongshu/01-algorithms.md"
    "marketing/xiaohongshu/02-system-design.md"
    "marketing/xiaohongshu/03-behavioral.md"
)

echo "📋 待发布内容："
echo ""
for i in "${!POSTS[@]}"; do
    echo "$((i+1)). ${POSTS[$i]}"
done
echo ""

echo "⏰ 建议发布时间："
echo "  - 第1篇：今晚 20:00 (流量高峰）"
echo "  - 第2篇：明天 20:00"
echo "  - 第3篇：后天 20:00"
echo ""

# 选择要发布的文章
echo "请选择要发布的内容："
read -p "输入编号 (1-3，或按a跳过): " choice

case $choice in
    1)
        POST_INDEX=0
        ;;
    2)
        POST_INDEX=1
        ;;
    3)
        POST_INDEX=2
        ;;
    a)
        echo "跳过，稍后手动发布"
        exit 0
        ;;
    *)
        echo "无效选择，退出"
        exit 1
        ;;
esac

POST_FILE="${POSTS[$POST_INDEX]}"
echo ""
echo "📄 选择了: $POST_FILE"
echo ""

# 显示内容
if [ -f "$POST_FILE" ]; then
    echo "---内容预览---"
    cat "$POST_FILE"
    echo "-------------------"
    echo ""
    echo "✅ 内容已准备"
    echo ""
    echo "📝 接下来的步骤："
    echo ""
    echo "1. 打开小红书 App 或网页版"
    echo "2. 复制上方内容到小红书编辑器"
    echo "3. 制作封面图（推荐工具：Canva、稿定设计）"
    echo "4. 添加话题标签"
    echo "5. 点击发布"
    echo ""
    echo "💡 发布技巧："
    echo "  - 最佳发布时间：晚上8-10点"
    echo "  - 话题：#程序员面试 #leetcode #算法 #技术面试"
    echo "  - 第一条评论置顶购买链接"
    echo ""
else
    echo "❌ 文件不存在: $POST_FILE"
    exit 1
fi
