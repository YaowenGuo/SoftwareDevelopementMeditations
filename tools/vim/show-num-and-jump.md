[TOC]

### show line number

:set number


gg:命令将光标移动到文档开头

G:命令将光标移动到文档末尾


vi编辑器中在命令行模式下输入G可以直接跳转到页面的底部

在命令行模式下输入1G可以跳转到页面的头部位置

更多在vi中移动编辑位置的命令说明如下：

    h Move left
    j Move down
    k Move up
    l Move right
    w Move to next word
    W Move to next blank delimited word
    b Move to the beginning of the word
    B Move to the beginning of blank delimted word
    e Move to the end of the word
    E Move to the end of Blank delimited word
    ( Move a sentence back
    ) Move a sentence forward
    { Move a paragraph back
    } Move a paragraph forward
    0 Move to the begining of the line
    $ Move to the end of the line
    1G Move to the first line of the file
    G Move to the last line of the file
    nG Move to nth line of the file
    :n Move to nth line of the file
    fc Move forward to c
    Fc Move back to c
    H Move to top of screen
    M Move to middle of screen
    L Move to botton of screen
    % Move to associated ( ), { }, [ ]
    ctrl-f Next page
    ctrl-b Backup page
    ctrl-d（down）可以向后翻半页，“ctlr-u”（up）可以向上翻半页。