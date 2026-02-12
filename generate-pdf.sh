#!/bin/bash

# 面试通关手册 - PDF生成脚本

echo "==================================="
echo "  面试通关手册 - PDF生成工具"
echo "==================================="
echo ""

# 检查是否有pandoc
if command -v pandoc &> /dev/null; then
    echo "✅ 检测到 pandoc，使用 pandoc 生成 PDF..."

    pandoc README.md \
        content/algorithms/01-arrays/two-sum.md \
        content/algorithms/01-arrays/3sum.md \
        content/algorithms/02-strings/longest-substring-without-repeating.md \
        content/system-design/tinyurl.md \
        content/behavioral/star-method.md \
        content/resume/ats-friendly.md \
        -o "面试通关手册-免费预览版.pdf" \
        --pdf-engine=xelatex \
        -V geometry:margin=1in \
        -V fontsize=12pt \
        --toc \
        --highlight-style=tango

    echo "✅ PDF 生成完成: 面试通关手册-免费预览版.pdf"
    exit 0
fi

# 如果没有pandoc，提供安装指导
echo "❌ 未检测到 pandoc"
echo ""
echo "请选择以下方式之一生成 PDF："
echo ""
echo "方式1: 使用 VS Code (推荐)"
echo "  1. 安装 'Markdown PDF' 扩展"
echo "  2. 打开 README.md"
echo "  3. 按 Cmd+Shift+P -> 选择 'Markdown PDF: Export (pdf)'"
echo ""
echo "方式2: 安装 pandoc"
echo "  brew install pandoc"
echo "  brew install --cask basictex"  # macOS"
echo "  然后重新运行此脚本"
echo ""
echo "方式3: 在线转换"
echo "  访问 https://www.markdowntopdf.com/"
echo "  上传 README.md 文件"
echo ""
echo "方式4: 使用 Typora"
echo "  1. 下载 Typora https://typora.io/"
echo "  2. 打开 README.md"
echo "  3. 文件 -> 导出 -> PDF"
echo ""

# 创建一个HTML版本，可以在浏览器中打印为PDF
echo "正在生成 HTML 版本..."
cat > "面试通关手册.html" <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>面试通关手册</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { border-bottom: 2px solid #333; padding-bottom: 10px; }
        h2 { border-bottom: 1px solid #ccc; padding-bottom: 5px; margin-top: 30px; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }
        pre code { background: none; padding: 0; }
        blockquote { border-left: 4px solid #ddd; margin: 0; padding-left: 20px; color: #666; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f4f4f4; }
        .page-break { page-break-after: always; }
    </style>
</head>
<body>
EOF

# 合并所有markdown文件并转换为HTML
for file in README.md \
    content/algorithms/01-arrays/two-sum.md \
    content/algorithms/01-arrays/3sum.md \
    content/algorithms/02-strings/longest-substring-without-repeating.md \
    content/system-design/tinyurl.md \
    content/behavioral/star-method.md \
    content/resume/ats-friendly.md
do
    if [ -f "$file" ]; then
        echo "<div class='page-break'>" >> "面试通关手册.html"
        cat "$file" | sed 's/^# /<h1>/;s/$/<\/h1>/;s/^## /<h2>/;s/$/<\/h2>/;s/^### /<h3>/;s/$/<\/h3>/' >> "面试通关手册.html"
        echo "</div>" >> "面试通关手册.html"
    fi
done

cat >> "面试通关手册.html" <<'EOF'
</body>
</html>
EOF

echo "✅ HTML 版本生成完成: 面试通关手册.html"
echo ""
echo "在浏览器中打开此文件，然后 Cmd+P 打印为 PDF"
echo ""
