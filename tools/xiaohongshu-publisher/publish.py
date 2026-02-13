#!/usr/bin/env python3
"""
小红书自动发布工具
支持微信登录方式
"""

import asyncio
from playwright.async_api import async_playwright
import sys

# 配置信息（从shell传入）
TITLE = sys.argv[1] if len(sys.argv) > 1 else "AI产品经理面试必备！"
BODY_FILE = sys.argv[2] if len(sys.argv) > 2 else "marketing/xiaohongshu-pm/01-product-thinking.md"

def read_content(filepath):
    """读取markdown文件内容"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取标题
    title_line = [line for line in content.split('\n') if '## 标题' in line][0]
    title = title_line.split('标题：')[1].strip() if title_line else TITLE

    # 提取正文（去除markdown标记）
    body = content
    body = body.replace('#', '').replace('*', '').replace('```', '')
    # 保留emoji

    # 提取标签
    tags_line = [line for line in content.split('\n') if '## 标签' in line][0]
    tags = tags_line.split('标签：')[1].strip().replace('#', ' ') if tags_line else "#产品经理 #AI产品 #面试准备"

    # 提取置顶话术
    pin_lines = []
    in_pin = False
    for line in content.split('\n'):
        if '## 评论区置顶话术' in line:
            in_pin = True
        elif in_pin:
            if line.strip() and not line.startswith('##') and not line.startswith('```'):
                pin_lines.append(line.strip())

    pin_top = '\n'.join(pin_lines).replace('`', '')

    return title, body, tags, pin_top

async def main():
    title, body, tags, pin_top = read_content(BODY_FILE)

    print("="*50)
    print("📱 小红书自动发布工具")
    print("="*50)
    print(f"\n📝 标题: {title}")
    print(f"🏷️ 标签: {tags}")
    print(f"💬 评论区话术: {pin_top[:50]}...")
    print("\n准备启动浏览器...")

    async with async_playwright() as browser:
        context = await browser.new_context()

        try:
            page = await context.new_page()
            await page.goto('https://www.xiaohongshu.com')

            print("\n" + "="*50)
            print("📋 请在浏览器中完成以下步骤：")
            print("="*50)
            print("1️⃣ 等待页面加载完成")
            print("2️⃣ 在登录方式中选择【微信登录】或【其他方式】")
            print("3️⃣ 如果需要扫码，会显示二维码")
            print("4️⃣ 完成登录后，脚本会自动检测并继续")
            print("5️⃣ 如果30秒内未检测到登录成功，请按Ctrl+C终止脚本")
            print("\n" + "="*50)

            # 等待登录
            print("⏸️ 等待登录...")

            # 检测登录成功的标志
            # 登录后页面URL会变，或者出现"发布"按钮
            logged_in = False

            for i in range(60):  # 等待最多60秒
                await asyncio.sleep(1)

                # 检查是否已经登录（多种方式判断）
                try:
                    # 方法1: 检查是否能找到发布按钮
                    has_publish = await page.locator('button:has-text("发布")').count() > 0

                    # 方法2: 检查URL是否包含特定参数
                    current_url = page.url

                    if has_publish or 'explore' not in current_url or 'publish' in current_url:
                        logged_in = True
                        print("\n✅ 检测到登录成功！")
                        break

                except:
                    pass

                if logged_in:
                    break

            if not logged_in:
                print("\n❌ 未检测到登录，可能需要手动操作")
                print("💡 建议：")
                print("1. 确认微信登录已授权")
                print("2. 手动点击一次【发布】按钮")
                print("3. 然后重新运行脚本")
                return

            # 开始发布流程
            print("\n" + "="*50)
            print("🚀 开始自动发布流程...")
            print("="*50)

            # 点击发布按钮
            print("1️⃣ 点击发布按钮...")
            try:
                await page.locator('text=发布').first.click()
                await page.wait_for_load_state('load')
            except:
                print("❌ 未找到发布按钮，请手动点击")
                print("💡 继续其他步骤...")

            # 等待编辑器加载
            print("2️⃣ 等待编辑器加载...")
            await asyncio.sleep(3)

            # 输入标题
            print(f"3️⃣ 输入标题: {title[:30]}...")
            try:
                await page.locator('textarea').first.fill(title)
                print("   ✅ 完成")
            except:
                print("   ❌ 失败，请手动输入")
                print("💡 等待10秒后继续...")
                await asyncio.sleep(10)

            # 输入正文
            print("4️⃣ 输入正文内容...")
            try:
                # 先点击文本区域
                await page.locator('textarea').first.click()
                await asyncio.sleep(1)

                # 粘贴内容
                await page.locator('textarea').first.fill(body)
                print("   ✅ 完成")
            except Exception as e:
                print(f"   ❌ 错误: {e}")
                print("💡 请手动粘贴后按回车继续...")
                input()
                await asyncio.sleep(2)

            # 滚动到顶部（话题标签在顶部）
            print("5️⃣ 滚动到顶部添加话题...")
            try:
                await page.evaluate('window.scrollTo(0, 0)')
                await asyncio.sleep(1)
            except:
                print("   ⚠️ 请手动滚动到顶部")
                print("💡 等待5秒后继续...")
                await asyncio.sleep(5)

            # 添加话题标签
            print(f"6️⃣ 输入话题: {tags[:30]}...")
            try:
                # 尝试找到话题输入框
                    tag_inputs = page.locator('input').all()
                    if len(tag_inputs) > 0:
                        await tag_inputs[0].fill(tags)
                        # 按回车确认
                        await page.keyboard.press('Enter')
                        await asyncio.sleep(1)
                        print("   ✅ 完成")
                    else:
                        # 找不到输入框，可能点击标签选择
                        print("   ⚠️ 未找到话题输入框")
                        print("💡 请手动添加话题后按回车...")
                        input()
            except:
                print("   ❌ 失败，请手动添加话题")
                print("💡 等待5秒后继续...")
                await asyncio.sleep(5)

            # 上传封面
            print("7️⃣ 上传封面图...")
            print("💡 请手动上传封面图片")
            print("💡 上传后按回车继续...")
            input()
            await asyncio.sleep(2)

            # 发布
            print("8️⃣ 发布笔记...")
            try:
                # 查找并点击发布按钮
                publish_btns = page.locator('button:has-text("发布")').all()
                if len(publish_btns) > 0:
                    await publish_btns[0].click()
                    print("   ✅ 已点击发布")
                else:
                    print("   ❌ 未找到发布按钮")
                    print("💡 请手动点击【发布】按钮")
                    input()
            except:
                print("   ❌ 错误")
                print("💡 请手动点击【发布】按钮")
                input()

            # 等待发布完成
            print("9️⃣ 等待发布完成...")
            await asyncio.sleep(5)

            # 发布置顶评论
            print("\n" + "="*50)
            print("💬 发布置顶评论...")
            print("="*50)

            try:
                # 返回首页或找笔记
                await page.goto('https://www.xiaohongshu.com')
                await asyncio.sleep(3)

                # 找到刚发布的笔记
                print("🔍 查找刚发布的笔记...")

                # 点击笔记
                first_note = page.locator('.note-item').first
                await first_note.click()
                await asyncio.sleep(2)

                # 点击评论区
                print("📝 点击评论区...")
                comment_section = page.locator('text=评论').first
                await comment_section.click()
                await asyncio.sleep(2)

                # 输入评论
                print(f"💬 输入评论: {pin_top[:50]}...")
                try:
                    comment_box = page.locator('textarea').first
                    await comment_box.fill(pin_top)
                    await asyncio.sleep(1)
                    print("   ✅ 完成")
                except Exception as e:
                    print(f"   ❌ 错误: {e}")
                    print("💡 请手动输入评论后按回车...")
                    input()

                # 发送评论
                print("🚀 发送评论...")
                try:
                    send_btn = page.locator('button:has-text("发送")').first
                    await send_btn.click()
                    await asyncio.sleep(2)
                    print("   ✅ 已发送")
                except:
                    print("   ⚠️ 请手动点击【发送】按钮")

                # 完成
                print("\n" + "="*50)
                print("🎉 发布流程完成！")
                print("="*50)
                print("\n💡 浏览器将保持打开60秒...")
                print("💡 你可以：")
                print("   - 查看发布效果")
                print("   - 继续编辑")
                print("   - 关闭浏览器")
                print("\n60秒后自动关闭...")

                await asyncio.sleep(60)

            except Exception as e:
                print(f"\n❌ 错误: {e}")
                print("\n💡 请手动完成剩余步骤")
                await asyncio.sleep(30)

        except Exception as e:
            print(f"\n❌ 脚本执行错误: {e}")
            finally:
                print("\n关闭浏览器...")
                await context.close()
                await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
