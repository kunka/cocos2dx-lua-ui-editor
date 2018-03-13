--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/19
-- Time: 上午10:10
-- To change this template use File | Settings | File Templates.
--

return {
    confirm = "确定",
    cancel = "取消",
    multi_language = "不同语言使用不同字体文件(英文:Klee.fnt,中文:Arial)。",
    zoom_button = "普通按钮",
    zoom_button_desc = "缩放按钮的大小由第一个child决定不能更改，child可以是任意类型node。（变更child大小后需要F1刷新一下，自动刷新暂未实现）",
    sprite_button = "图片按钮",
    sprite_button_desc = "图片按钮使用3张图片代表3个状态Normal, Selected（点击临时状态不能保持）, Disabled；有2种选中模式，切换：切换状态时切换图片；叠加：切换状态时Normal图片不变，叠加Selected或者Disabled图片。",
    toggle_button = "Toggle按钮",
    toggle_button_desc = "Toggle按钮使用Tag控制child切换显示，所有tag等于SelectedTag的child为visible状态，大小跟普通按钮一样由第一个child决定。",
    check_box = "CheckBox",
    check_box_desc = "CheckBox继承于SpriteButton，点击会自动切换Selected状态（可以保持）。",
    some_text = "When a country Taxes our products coming in at, say, 50%, and we Tax the same product coming into our country at ZERO, not fair or smart. We\
will soon be starting RECIPROCAL TAXES so that we will charge the same thing as they charge us. $800 Billion Trade Deficit-have no choice!",
}