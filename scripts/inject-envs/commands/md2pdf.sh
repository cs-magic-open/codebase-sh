export md2pdf() {
  echo "== started md2pdf =="

  input_file="" # required
  output_dir="$HOME/Documents" # default output directory

  while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
      param="${1/--/}"
      declare $param="$2"
    fi
    shift
  done

  if [[ -z $input_file ]]; then
    echo -e "\nPlease call 'md2pdf --input_file <markdown file>' to run this command\n"
    return 1
  fi

  # 提取文件名（不含扩展名）作为标题
  filename=$(basename "$input_file" .md)
  output_file="${output_dir}/${filename}.pdf"

  # 创建临时文件以添加头部信息
  temp_file=$(mktemp)

  # 添加头部信息到临时文件
  cat > "$temp_file" << EOF
---
title: "${filename}"
subtitle: "公众号：手工川"
date: $(date +%Y-%m-%d)
author: [南川]
lang: "zh-CN"
titlepage: true
titlepage-color: "5D1EB1"         # 飞脑科技主紫色
titlepage-text-color: "FFFFFF"
titlepage-rule-color: "FFE600"    # 强调黄作为分隔线
titlepage-rule-height: 2
titlepage-logo: /Users/mark/飞脑科技/assets/branding/cs-magic_logo_white_1280.png
---

EOF

  # 将原始文件内容添加到临时文件
  cat "$input_file" >> "$temp_file"

  # 确保输出目录存在
  mkdir -p "$output_dir"

  # 执行pandoc命令
  echo "Converting $input_file to $output_file..."
  pandoc "$temp_file" \
    -o "$output_file" \
    -f markdown+wikilinks_title_after_pipe \
    --template eisvogel \
    -t pdf \
    --pdf-engine=xelatex \
    -V mainfont="Songti SC" \
    -V CJKmainfont="Songti SC"

  # 删除临时文件
  rm "$temp_file"

  echo "已生成PDF: $output_file"
  osascript -e "display notification \"$output_file 已成功生成\" with title \"md2pdf 完成\""
}
