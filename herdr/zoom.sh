#!/bin/bash
# prefix+z の代わりに呼ぶ。ペインのズームを切り替え、ズーム中はペイン名の末尾に
# 虫眼鏡 (U+1F50D) を付ける。タブ名に付く Z や tab bar の ZOOM だけでは気付きにくいため、
# ペイン枠のラベル・サイドバー (赤字のルール)・外側の端末タイトルにも出す。
pane="${HERDR_ACTIVE_PANE_ID:-$HERDR_PANE_ID}"
[ -n "$pane" ] || exit 0
suffix=" 🔍"

zoomed=$(herdr pane zoom "$pane" --toggle | jq -r '.result.zoom.zoomed')
label=$(herdr pane list | jq -r --arg id "$pane" '.result.panes[] | select(.pane_id == $id) | .label // empty')
base="${label%"$suffix"}"

if [ "$zoomed" = "true" ]; then
  herdr pane rename "$pane" "${base:-pane}$suffix" >/dev/null
elif [ "$label" != "$base" ]; then
  herdr pane rename "$pane" "$base" >/dev/null
fi
