# vidar

my toy OS

[30日でできる!OS自作入門](http://hrb.osask.jp/) をやっていくレポジトリ


| 領域                             | 概要               |
| :--                              | :--                |
| 0x00007c00 ~ 0x00007dff          | ブートセクタ       |
| 0x00007e00 ~ 0x0009fc00          | 自由に使って良い   |
| 0x00008000 ~ 0x000081ff(512byte) | ブートセクタの内容 |
| 0x00008200 ~ 0x00034fff(180KB)   | ファイルの内容     |
| 0x000a0000 ~ 0x000fffff          | ビデオメモリ       |

C0-H0-S1はブートセクタで，今の所，C0-H0-S1 ~ C9-H1-S18 が読み込まれる．

> 計180KBが読み込まれる．
> `18 * 10 * 2 * 512 = 184320 byte = 180KB`

`0x34fff`まではファイルの内容が入っている．
> `0x34fff` になる理由がよく分かってない．
> `0x08200 + 184320 = 0x35200` のはずで，どうやってその値が出てきたんだろう

ファイルの内容については，今の所10シリンダ分を読むようにしている．

0x4200に`vidar.sys`の内容がある．
`0x8000 + 0x4200 = 0xc200` なので，`0xc200` にジャンプすれば，`vider.sys` の内容を実行できる．

`vidar.sys` 実行前に， `0xff0` に，読み込んだシリンダ数を書き込むようにしてある．
> `0xff0` なのはなんでなんだろう．．．．
