#!/bin/bash

echo "======================================="
echo "  小红书自动发布工具"
echo "======================================="
echo ""

# 检查是否安装了playwright
if ! command -v playwright &> /dev/null; then
    echo "❌ 未安装Playwright，正在安装..."
    npm install -g playwright
    echo "✅ Playwright安装完成"
fi

# 询问发布内容
echo "📋 请选择要发布的内容："
echo "1. 产品思维介绍"
echo "2. AI产品专题"
echo "3. 行为面试技巧"
read -p "输入编号 (1-3): " choice

case $choice in
    1)
        CONTENT_FILE="marketing/xiaohongshu-pm/01-product-thinking.md"
        TITLE="AI产品经理面试必备！这份产品思维手册让我拿到了3个大厂offer"
        ;;
    2)
        CONTENT_FILE="marketing/xiaohongshu-pm/02-ai-products.md"
        TITLE="AI产品经理必看！这份对话系统设计指南救了我的面试"
        ;;
    3)
        CONTENT_FILE="marketing/xiaohongshu-pm/03-behavioral.md"
        TITLE="AI产品经理面试必看！50+STAR模板让我再也不怕行为题"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "📄 选择了: $TITLE"
echo "📁 文件: $CONTENT_FILE"
echo ""

# 检查文件是否存在
if [ ! -f "$CONTENT_FILE" ]; then
    echo "❌ 文件不存在: $CONTENT_FILE"
    exit 1
fi

# 提取内容
echo "📖 正在提取内容..."
TITLE=$(grep "^## 标题" "$CONTENT_FILE" | sed 's/^## 标题//' | xargs)
BODY=$(sed -n '/^## 正文内容$/,/^## 封面文案$/p' "$CONTENT_FILE" | sed '/^## /d')
TAGS=$(grep "^## 标签" "$CONTENT_FILE" | sed 's/^## 标签//' | sed 's/#/ /g')
PIN_TOP=$(sed -n '/^## 评论区置顶话术$/,/^```$/p' "$CONTENT_FILE" | sed '1d;$d')

echo "✅ 内容提取完成"
echo ""

# 显示提取的内容
echo "======================================="
echo "标题："
echo "$TITLE"
echo ""
echo "======================================="
echo "正文："
echo "$BODY"
echo ""
echo "======================================="
echo "话题标签："
echo "$TAGS"
echo ""
echo "======================================="
echo "评论区话术："
echo "$PIN_TOP"
echo "======================================="
echo ""

# 创建Python脚本
PYTHON_SCRIPT="
import asyncio
from playwright.async_api import async_playwright
import json

# 配置
TITLE = \"\"$TITLE\"\"
BODY = '''$BODY'''
TAGS = '$TAGS'
PIN_TOP = '''$PIN_TOP'''

# 登录并发布
async def publish_xiaohongshu():
    print('🚀 启动浏览器...')

    async with async_playwright() as browser:
        # 创建上下文
        context = await browser.new_context()

        try:
            # 打开小红书
            print('📱 打开小红书...')
            page = await context.new_page()
            await page.goto('https://www.xiaohongshu.com')

            # 等待用户手动登录
            print('⏸️ 请在浏览器中完成以下步骤：')
            print('1. 选择微信登录（如果需要）')
            print('2. 完成登录验证')
            print('3. 登录完成后，按回车继续...')
            input()

            # 点击发布
            print('✅ 点击发布按钮...')
            try:
                publish_btn = page.locator('text=发布').first
                await publish_btn.click()
                await page.wait_for_timeout(10000).wait_for_load_state()

                # 输入标题
                print('📝 输入标题...')
                title_input = page.locator('textarea[placeholder*=\"填写标题\"]').first
                await title_input.fill(TITLE)

                # 输入正文
                print('📝 输入正文...')
                content_input = page.locator('textarea[placeholder*=\"填写正文\"]').first
                await content_input.fill(BODY)

                # 滚动到顶部（话题标签位置）
                print('🏷️ 添加话题标签...')
                await page.evaluate('window.scrollTo(0, 0)')

                # 输入话题标签
                print('🏷️ 输入话题...')
                tag_input = page.locator('input[placeholder*=\"添加话题\"]').first
                await tag_input.fill(TAGS)

                # 上传封面
                print('📸️ 请上传封面图...')

                # 等待用户上传
                while True:
                    has_image = await page.evaluate('''() => {
                        return document.querySelector('.upload-input') !== null;
                    }''')

                    if has_image:
                        break
                    await asyncio.sleep(2)

                print('✅ 封面已上传')

                # 发布
                print('🚀 发布笔记...')
                publish_btn = page.locator('button:has-text(\"发布\")').first
                await publish_btn.click()

                # 等待发布完成
                await asyncio.sleep(3)

                # 发布置顶评论
                print('💬 发布置顶评论...')
                await page.goto('https://www.xiaohongshu.com')

                # 找到刚发布的笔记
                await asyncio.sleep(5)

                # 点击评论
                comment_section = page.locator('text=评论').first
                await comment_section.click()

                # 等待评论框加载
                await asyncio.sleep(2)

                # 输入评论
                comment_input = page.locator('textarea[placeholder*=\"说点什么...\"]').first
                await comment_input.fill(PIN_TOP)

                # 发送评论
                send_btn = page.locator('button:has-text(\"发送\")').first
                await send_btn.click()

                print('✅ 发布成功！')

                # 保持浏览器打开
                print('🎉 完成！浏览器将保持打开...')

                await asyncio.sleep(60)

        except Exception as e:
            print(f'❌ 错误: {e}')
            print('💡 建议：请手动完成剩余步骤')

        finally:
            await context.close()
            await browser.close()

if __name__ == '__main__':
    asyncio.run(publish_xiaohongshu())
"

# 保存Python脚本
echo "$PYTHON_SCRIPT" > publish_xiaohongshu.py
echo "✅ Python脚本已创建: publish_xiaohongshu.py"
echo ""

# 运行脚本
echo "🚀 启动自动发布..."
python3 publish_xiaohongshu.py
