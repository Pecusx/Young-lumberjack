import json
import sys

def print_lines(
        dta, line_from: int, line_to: int, skip_left: int = 0, skip_right: int = 0, f=sys.stdout,):
    for d in dta[line_from:line_to]:
        print(
            f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0 + skip_left*2, len(d) - skip_right*2, 2)]),
            file=f)

def write_asm(atrview, out, page, line_from, line_to, skip_left, skip_right):
    with open(atrview, 'r', encoding='utf-8-sig') as f:
        s = json.load(f)
    for p in s['Pages']:
        if (isinstance(page, int) and p['Nr'] == page) or (isinstance(page, str) and p['Name'] == page):
            dta = p['View']
            width = p['Width'] * 2  # 2 hex chars per byte
            dtas = [dta[i * width:(i + 1) * width] for i in range(len(dta) // width)]
            break

    with open(out, 'wt') as f:
        print_lines(dtas, line_from, line_to, skip_left,skip_right, f)


write_asm(
    atrview='title_fonts.atrview',
    out='over_screen.asm',
    page=5,
    line_from=0,
    line_to=13,
    skip_left=0,
    skip_right=8)

write_asm(
    atrview="title.atrview",
    out='title_logo.asm',
    page=1,
    line_from=2,
    line_to=2+8,
    skip_left=0,
    skip_right=8)

write_asm(
    atrview="title.atrview",
    out='title_timber.asm',
    page=1,
    line_from=12,
    line_to=12+12,
    skip_left=0,
    skip_right=8)

write_asm(
    atrview="title_fonts.atrview",
    out='difficulty_texts.asm',
    page=4,
    line_from=0,
    line_to=0+2,
    skip_left=0,
    skip_right=0)

write_asm(
    atrview="title_fonts.atrview",
    out='go.asm',
    page='GO',
    line_from=0,
    line_to=0+4,
    skip_left=0,
    skip_right=8)
