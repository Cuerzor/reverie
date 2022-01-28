------------------------------------------------------------------
-----  Basic English descriptions based on Platinumgod.co.uk -----
------------------------------------------------------------------
-- FORMAT: Item ID | Name| Description
-- '#' = starts new line of text
-- Special character markup:
-- ↑ = Up Arrow   |  ↓ = Down Arrow    | ! = Warning
local Collectibles = THI.Collectibles;
local Trinkets = THI.Trinkets;
local Players = THI.Players;

local EIDInfo = {};

EIDInfo.Entries = {
    ["Lunatic"] = "{{ColorPurple}}疯狂模式{{CR}}：",
    ["TouhouCharacter"] = "{{ColorPink}}对应：{{CR}}"
}

EIDInfo.Transformations = {
    ReverieMusician = "音乐家套装",
}

EIDInfo.Collectibles = {
    [Collectibles.YinYangOrb.Item] = {
        Name = "阴阳玉",
        Description = "扔出一个反弹的阴阳玉#造成20点碰撞伤害",
        BookOfVirtues = "阴阳玉火焰",
        TouhouCharacter = "博丽灵梦"
    },
    [Collectibles.DarkRibbon.Item] = {
        Name = "黑暗缎带",
        Description = "玩家具有一个伤害光环，每秒造成10.71点伤害#↑ 站在光环中+50%伤害",
        TouhouCharacter = "露米娅"
    },
    [Collectibles.DYSSpring.Item] = {
        Name = "大妖精之泉",
        Description = "+2魂心#回满血量#回满充能#有10%的几率将心转化为妖精#妖精能够回满血量且给予1颗魂心",
        TouhouCharacter = "大妖精"
    },
    [Collectibles.DragonBadge.Item] = {
        Name = "虹龙徽章",
        Description = "向敌人冲刺#冲刺时无敌#击中敌人时释放拳弹并获得额外无敌时间",
        BookOfVirtues = "拳弹",
        TouhouCharacter = "红美铃"
    },
    [Collectibles.Grimoire.Item] = {
        Name = "帕秋莉的魔导书",
        Description = "在本层内获得随机眼泪特效#特效：跟踪，魅惑，燃烧，减速，中毒，磁化，石头#如果所有7个效果都已获得，将玩家传送到错误房",
        BookOfVirtues = "七曜子弹/错误子弹",
        TouhouCharacter = "帕秋莉"
    },
    [Collectibles.MaidSuit.Item] = {
        Name = "女仆服装",
        Description = "生成{{Card21}}XXI - 世界#进入房间后暂停所有敌人#{{Card21}}XXI - 世界具有时停飞刀效果#清理房间后有几率生成{{Card21}}XXI - 世界",
        TouhouCharacter = "十六夜{{ERROR}}夜"
    },
    [Collectibles.VampireTooth.Item] = {
        Name = "吸血鬼之牙",
        Description = "↑ +1伤害#↑ +2幸运#飞行#!!! {{Card20}}XIX - 太阳会伤害玩家的所有红心#{{Card19}}XVIII - 月亮会将玩家传送到究极隐藏房",
        TouhouCharacter = "蕾米莉亚·斯卡蕾特"
    },
    [Collectibles.Koakuma.Item] = {
        Name = "小恶魔宝宝",
        Description = "大子弹跟班#每颗眼泪造成3点伤害#与{{Bookworm}}书虫套装和{{Collectible" ..
            Collectibles.Grimoire.Item .. "}}帕秋莉的魔导书具有协同效应",
        TouhouCharacter = "小恶魔"
    },
    [Collectibles.Destruction.Item] = {
        Name = "毁灭",
        Description = "召唤一个会爆炸和碎成碎片的陨石#本房间内，持续在以撒的位置掉落陨石",
        BookOfVirtues = "燃烧子弹，火焰熄灭后爆炸",
        TouhouCharacter = "芙兰朵露·斯卡蕾特"
    },
    [Collectibles.MarisasBroom.Item] = {
        Name = "魔理沙的扫帚",
        Description = "飞行#↑ 每有一种蘑菇道具，+1伤害，-0.5射击延迟，+0.3速度",
        TouhouCharacter = "雾雨魔理沙"
    },
    [Collectibles.FrozenSakura.Item] = {
        Name = "冻结的樱花",
        Description = "玩家具有一个伤害光环，每秒造成4.3点伤害#减速光环内的敌人和子弹#冻结被光环杀死的敌人",
        TouhouCharacter = "蕾蒂·霍瓦特洛克"
    },
    [Collectibles.ChenBaby.Item] = {
        Name = "橙宝宝",
        Description = "向前冲刺的跟班#造成3.5点接触伤害，并飞向另一个最近的敌人#九尾之尾会翻倍其攻击力",
        TouhouCharacter = "橙"
    },
    [Collectibles.ShanghaiDoll.Item] = {
        Name = "上海人偶",
        Description = "环绕物#向接近玩家的敌人冲刺并造成3.5点伤害",
        TouhouCharacter = "爱丽丝·玛格特罗伊德"
    },
    [Collectibles.MelancholicViolin.Item] = {
        Name = "忧郁提琴",
        Description = "生成一个存在10秒的小提琴#↑ 范围内-4射击延迟#减速范围内的敌人",
        BookOfVirtues = "减速泪弹",
        TouhouCharacter = "露娜萨·普利兹姆利巴"
    },
    [Collectibles.ManiacTrumpet.Item] = {
        Name = "狂躁小号",
        Description = "生成一个存在10秒的小号#↑ 范围内+50%伤害#伤害范围内的敌人",
        BookOfVirtues = "混乱泪弹",
        TouhouCharacter = "梅露兰·普利兹姆利巴"
    },
    [Collectibles.IllusionaryKeyboard.Item] = {
        Name = "幻想键盘",
        Description = "生成一个存在10秒的键盘#↑ 范围内+1速度#消除范围内的子弹",
        BookOfVirtues = "魅惑泪弹",
        TouhouCharacter = "莉莉卡·普利兹姆利巴"
    },
    [Collectibles.DeletedErhu.Item] = {
        Name = "被删除的二胡",
        Description = "移除本房间内的所有敌人和障碍物#被移除的敌人和障碍物在本局游戏中不再出现#该道具消失",
        BookOfVirtues = "错误火焰",
        TouhouCharacter = "{{ERROR}}月麟"
    },
    [Collectibles.Roukanken.Item] = {
        Name = "楼观剑",
        Description = "在18秒内使用剑斩击，每击造成5x玩家伤害，并可摧毁障碍物#使用时再次使用会向移动方向冲刺，对路径上的敌人造成2x玩家伤害#使用冲刺杀敌会回复充能",
        BookOfVirtues = "近战火焰，能够摧毁障碍物",
        TouhouCharacter = "魂魄妖梦"
    },
    [Collectibles.FanOfTheDead.Item] = {
        Name = "死者之扇",
        Description = "飞行#幽灵眼泪#将所有心之容器和魂心转化为额外生命",
        TouhouCharacter = "西行寺幽幽子"
    },
    [Collectibles.FriedTofu.Item] = {
        Name = "油炸豆腐",
        Description = "↑ +1心之容器",
        TouhouCharacter = "八云蓝"
    },
    [Collectibles.OneOfNineTails.Item] = {
        Name = "九尾之尾",
        Description = "生成一个宝宝商店的道具#进入新的一层后生成宝宝商店的道具#↑ 每有一个跟班，伤害提升#在拥有9个跟班时伤害达到最大值，为150%#橙宝宝算作三个跟班。",
        TouhouCharacter = "八云蓝"
    },
    [Collectibles.Gap.Item] = {
        Name = "隙间",
        Description = "生成连接所有房间的传送地板#在地板上使用隙间以使用地板#包括究极隐藏",
        BookOfVirtues = "传送泪弹",
        TouhouCharacter = "八云紫"
    },
    [Collectibles.Starseeker.Item] = {
        Name = "寻星者",
        Description = "进入有道具的房间后生成三个水晶球#拾取水晶球后其他两个消失#下一个该房间类型的道具被选中的道具替换#每有一个道具多选择一轮",
        TouhouCharacter = "宇佐见莲子"
    },
    [Collectibles.Pathseeker.Item] = {
        Name = "寻道者",
        Description = "每层开始在起始房间生成显示本层所有房间的地板#如果玩家拥有隙间，可以使用它们进行传送",
        TouhouCharacter = "玛艾露贝莉·赫恩"
    },
    [Collectibles.GourdShroom.Item] = {
        Name = "葫芦菇",
        Description = "以撒受到伤害后转换疏密形态#↑ 密形态伤害x1.35，射程+3，大小x1.5并且可以踩碎石头#↑ 疏形态射击延迟x0.7，速度+0.5，大小x0.75并且召唤5个迷你以撒",
        TouhouCharacter = "伊吹萃香"
    },
    [Collectibles.JarOfFireflies.Item] = {
        Name = "萤火虫罐",
        Description = "放出12个友方着火苍蝇#着火苍蝇会扑向敌人，接触时爆炸并造成等同于玩家伤害的伤害#清除黑暗诅咒",
        BookOfVirtues = "3个熄灭后生成着火苍蝇的火焰",
        TouhouCharacter = "莉格露·奈特巴格"
    },
    [Collectibles.SongOfNightbird.Item] = {
        Name = "夜雀之歌",
        Description = "永久具有黑暗诅咒#远离以撒的敌人被混乱，并且受到的伤害增加50%",
        TouhouCharacter = "米斯蒂娅·萝蕾拉"
    },
    [Collectibles.BookOfYears.Item] = {
        Name = "岁月史书",
        Description = "移除品质最低的一个被动道具，生成一个随机道具。",
        BookOfVirtues = "熄灭后生成{{Collectible"..CollectibleType.COLLECTIBLE_MISSING_PAGE_2.."}}遗失书页2",
        TouhouCharacter = "上白泽慧音"
    },
    [Collectibles.RabbitTrap.Item] = {
        Name = "兔之陷阱",
        Description = "↑ +1幸运#进入有敌人的房间后生成陷阱#陷阱立即杀死非飞行怪物，并且对BOSS造成每20帧30点的伤害",
        TouhouCharacter = "因幡天为"
    },
    [Collectibles.Illusion.Item] = {
        Name = "幻象",
        Description = "在玩家中等距离外生成四个幻象#每7帧造成玩家伤害一半的接触伤害#会朝射击方向发射血泪，伤害3.5",
        TouhouCharacter = "铃仙·优昙华院·因幡"
    },
    [Collectibles.PeerlessElixir.Item] = {
        Name = "无双之药",
        Description = "↑ 在本层中+0.6伤害，+0.6射速并且+0.3速度#!!! 本层第四次使用后，以撒爆炸并死亡",
        BookOfVirtues = "强力绿色火焰，熄灭后爆炸",
        TouhouCharacter = "八意永琳"
    },
    [Collectibles.DragonNeckJewel.Item] = {
        Name = "龙颈之玉",
        Description = "每隔3秒在以撒最近的敌人处降下圣光#圣光会产生5颗眼泪，每颗造成3.5点伤害",
        TouhouCharacter = "蓬莱山辉夜"
    },
    [Collectibles.BuddhasBowl.Item] = {
        Name = "佛御钵之石",
        Description = "在你受到伤害后，防止下一次伤害",
        TouhouCharacter = "蓬莱山辉夜"
    },
    [Collectibles.RobeOfFirerat.Item] = {
        Name = "火鼠的皮衣",
        Description = "生成一个火焰环绕物#穿过火焰的子弹会变成新的火焰#免疫火焰伤害",
        TouhouCharacter = "蓬莱山辉夜"
    },
    [Collectibles.SwallowsShell.Item] = {
        Name = "燕的子安贝",
        Description = "进入新层后生成一个{{AngelRoom}}天使房道具#每有一个{{连体}}连体！套装道具，生成一颗魂心#受伤后消失",
        TouhouCharacter = "蓬莱山辉夜"
    },
    [Collectibles.JeweledBranch.Item] = {
        Name = "蓬莱玉枝",
        Description = "以撒发射眼泪，在周围形成一个环#如果眼泪数量达到上限5，其中一个会脱离环并向最近的敌人飞去",
        TouhouCharacter = "蓬莱山辉夜"
    },
    [Collectibles.AshOfPheonix.Item] = {
        Name = "不死鸟灰烬",
        Description = "以撒死后变为灰烬，并生成四条火浪#如果灰烬在2秒内未受到任何伤害，复活以撒并再次生成火浪#!!! 自伤不触发该效果",
        TouhouCharacter = "藤原妹红"
    },

    [Collectibles.TenguCamera.Item] = {
        Name = "天狗相机",
        Description = "持有时显示扇形范围，使用后石化范围内的敌人并消除子弹，并对这些敌人造成5点伤害#根据拍到的敌人和子弹数量生成分数和奖励：#10分：1硬币 12分：1钥匙#16分：1炸弹 22分：1药丸#30分：1卡牌 40分：1饰品#52分：1魂心#66分：底片#82分：撕裂的照片#100分：死亡证明",
        BookOfVirtues = "将敌弹变为无法发射眼泪的黑色火焰",
        TouhouCharacter = "射命丸文"
    },
    [Collectibles.SunflowerPot.Item] = {
        Name = "向日葵盆栽",
        Description = "以撒头上的向日葵跟班#在清理房间后，生成一个掉落物或道具#!!! 以撒受伤后，向日葵死亡。然后爆炸并对以撒造成额外一颗心的伤害#下一层复活#{{Collectible" ..
            CollectibleType.COLLECTIBLE_BFFS .. "}}好朋友一辈子！会让向日葵改为掉落两个",
        TouhouCharacter = "风见幽香"
    },
    [Collectibles.ContinueArcade.Item] = {
        Name = "继续？",
        Description = "+3硬币#以撒死后支付3钱币在本房间内复活#复活后所有红心回满#每次复活，所需的钱币数量变为三倍",
        TouhouCharacter = "小野塚小町"
    },
    [Collectibles.RodOfRemorse.Item] = {
        Name = "悔悟棒",
        Description = "对以撒造成一颗心的伤害（优先扣除红心），并触发一次献祭房的效果#献祭次数与任何献祭房无关，并会在进入下一层后重置",
        BookOfVirtues = "熄灭后有25%的几率掉落红心",
        TouhouCharacter = "四季映姬·夜摩仙那度"
    },

    [Collectibles.IsaacsLastWills.Item] = {
        Name = "以撒的遗书",
        Description = "!!! 一次性！#将当前房间中的所有道具和饰品送到下一局#!!! 在挑战或种子局中不起作用#!!! 如果MOD被关闭，没有效果，直到MOD被再次开启",
        BookOfVirtues = "下一局开始时获得一圈强力火焰",
        TouhouCharacter = "稗田阿求"
    },

    [Collectibles.LeafShield.Item] = {
        Name = "飞叶护盾",
        Description = "每三秒生成飞叶护盾#每7帧造成4点伤害，并阻挡所有敌弹#按下射击键会将护盾发射出去",
        TouhouCharacter = "秋静叶"
    },
    [Collectibles.BakedSweetPotato.Item] = {
        Name = "烤红薯",
        Description = "↑ +1体力提升#↑ +5伤害，并在2分钟内衰减完毕",
        TouhouCharacter = "秋穣子"
    },
    [Collectibles.BrokenAmulet.Item] = {
        Name = "破碎的护身符",
        Description = "↓ -3幸运#眼泪具有黑色光圈，光圈中的敌人每2帧受到伤害#以撒幸运越低，光圈越大，伤害越高#0幸运时，伤害达到最小值，为20%玩家伤害#-5幸运时，伤害达到最大值，为80%玩家伤害",
        TouhouCharacter = "键山雏"
    },
    [Collectibles.ExtendingArm.Item] = {
        Name = "延展手臂",
        Description = "向一个方向发射钩爪#击中的敌人会被石化，并且被拉到以撒面前#击中障碍物后，将以撒拉到障碍物前方#击中掉落物后，将其拉到以撒面前#直到拉取结束，以撒无敌",
        BookOfVirtues = "伸长时产生停止的临时绿色火焰",
        TouhouCharacter = "河城荷取"
    },
    [Collectibles.Benediction.Item] = {
        Name = "祈愿",
        Description = "可以在任何充能时使用#直到下一层开始，根据当前充能获得一个天使房道具："..
        "#1: {{Collectible"..CollectibleType.COLLECTIBLE_HALLOWED_GROUND.."}}圣地大便"..
        "#2: {{Collectible"..CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL.."}}守护天使"..
        "#3: {{Collectible"..CollectibleType.COLLECTIBLE_ANGELIC_PRISM.."}}天使棱镜".. 
        "#4: {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_WATER.."}}圣水"..
        "#5: {{Collectible"..CollectibleType.COLLECTIBLE_TRISAGION.."}}三圣颂"..
        "#6: {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_LIGHT.."}}圣光"..
        "#7: {{Collectible"..CollectibleType.COLLECTIBLE_HOLY_MANTLE.."}}神圣斗篷"..
        "#8: {{Collectible"..CollectibleType.COLLECTIBLE_SALVATION.."}}救恩"..
        "#9: {{Collectible"..CollectibleType.COLLECTIBLE_GODHEAD.."}}神性"..
        "#10: {{Collectible"..CollectibleType.COLLECTIBLE_REVELATION.."}}终末天启"..
        "#11: {{Collectible"..CollectibleType.COLLECTIBLE_SACRED_HEART.."}}圣心"..
        "#12: {{Collectible"..CollectibleType.COLLECTIBLE_SACRED_ORB.."}}十字圣球",
        BookOfVirtues = "灵火血量根据充能而定",
        TouhouCharacter = "东风谷早苗"
    },


    
    [Collectibles.RuneSword.Item] = {
        Name = "符文佩剑",
        Description = "拿起时，生成一个随机符文#将持有的符文镶嵌在该道具上，变为该道具的被动效果#将部分随机卡牌替换为符文",
        BookOfVirtues = "符文灵火",
        TouhouCharacter = "绵月依姬"
    },

    
    [Collectibles.PlagueLord.Item] = {
        Name = "瘟疫领主",
        Description = "使周围敌人中毒#中毒的敌人死亡后留下毒云",
        TouhouCharacter = "黑谷山女"
    },
    [Collectibles.GreenEyedEnvy.Item] = {
        Name = "绿眼的嫉妒",
        Description = "进入房间后，将本房间所有敌人的生命值降为40%#在它们死亡后，生成两个具有20%生命值的小型复制",
        TouhouCharacter = "水桥帕露西"
    },
    [Collectibles.OniHorn.Item] = {
        Name = "鬼之角",
        Description = "↑ +1攻击力#每当以撒受到伤害：#第一次：生成一圈裂地波#第二次：生成三圈裂地波，并爆炸#第三次：生成全屏裂地波，并产生巨大爆炸#第三次受伤或者进入新的房间后，受伤计数器重置#!!! 卖血机、忏悔室和乞丐不触发该效果",
        TouhouCharacter = "星熊勇仪"
    },
    [Collectibles.PsycheEye.Item] = {
        Name = "精神眼",
        Description = "眼睛跟班#每秒发射一颗精神控制眼泪，将击中的小怪变为友方#被击中的BOSS会被魅惑5秒#移除迷途、致盲和未知诅咒",
        TouhouCharacter = "古明地觉"
    },
    [Collectibles.Technology666.Item] = {
        Name = "科技666",
        Description = "每秒额外发射一条黄色硫磺火，造成25%的玩家伤害#如果硫磺火杀死敌人，敌人爆炸，并在敌人位置爆出6条新的硫磺火激光#爆炸不会伤到玩家，并且爆出的硫磺火激光具有同样的效果",
        TouhouCharacter = "灵乌路空"
    },
    [Collectibles.PsychoKnife.Item] = {
        Name = "疯人刀",
        Description = "处决附近的一个敌人#会直接杀死小怪，对BOSS造成大量破甲伤害，并将周围的敌人震开#只能处决近距离的敌人。如果敌人生命值过低或处在异常状态，处决范围翻倍",
        BookOfVirtues = "黑色火焰",
        TouhouCharacter = "古明地恋"
    },

    [Collectibles.DowsingRods.Item] = {
        Name = "探宝棒",
        Description = "使部分普通石头隐藏一些物品#发出声波探测这些石头#距离越近声波越频繁",
        TouhouCharacter = "娜兹玲"
    },
    [Collectibles.ScaringUmbrella.Item] = {
        Name = "惊吓唐伞",
        Description = "阻挡上方子弹#本房间射击后不停掉落眼泪雨#随机恐惧周围敌人#在玩家没有危险时惊吓玩家",
        TouhouCharacter = "多多良小伞"
    },
    [Collectibles.Pagota.Item] = {
        Name = "毗沙门天的宝塔",
        Description = "!!! 一次性！#需要钱币作为充能#将整层变为金色，并且将所有掉落物和便便变为金色版本#点金所有敌人5秒",
        BookOfVirtues = "12个金色火焰，发射点金眼泪",
        TouhouCharacter = "寅丸星"
    },
    [Collectibles.SorcerersScroll.Item] = {
        Name = "魔人经卷",
        Description = "!!! 移除玩家所有魂心（不致死）#每移除半颗魂心：#↑ +0.2攻击力#↑ +0.2射速#↑ +0.03速度#↑ +0.4射程",
        BookOfVirtues = "咒文火焰，提升玩家所有属性",
        TouhouCharacter = "圣白莲"
    },
    [Collectibles.SaucerRemote.Item] = {
        Name = "飞碟遥控器",
        Description = "生成一个吸走掉落物和道具的UFO#摧毁UFO后生成双倍奖励#15秒后UFO逃走",
        BookOfVirtues = "可以通过消耗3个颜色相同，或完全不同的UFO火焰来免费使用",
        TouhouCharacter = "封兽鵺"
    },

    [Collectibles.TenguCellphone.Item] = {
        Name = "天狗手机",
        Description = "网购！#网购货物一次只有三个，并且每个房间都不一样#货物根据当前房间类型决定#购买后的货物会快递到下一层#可被{{Collectible" ..
            CollectibleType.COLLECTIBLE_STEAM_SALE .. "}}Steam大促降价",
        BookOfVirtues = "点金泪弹",
        TouhouCharacter = "姬海棠果"
    },

    [Collectibles.MountainEar.Item] = {
        Name = "山谷之耳",
        Description = "11%的几率发射回声眼泪，在房间中反弹#击中玩家后消失，并且暂时提升玩家攻击力#8幸运：100%",
        TouhouCharacter = "幽谷响子"
    },
    [Collectibles.ZombieInfestation.Item] = {
        Name = "僵尸感染",
        Description = "获得时将所有红心替换为腐心#每当一个小怪死亡，生成一个它的友方全新复制#该复制无法被带出房间",
        TouhouCharacter = "宫古芳香"
    },
    [Collectibles.WarppingHairpin.Item] = {
        Name = "穿墙发簪",
        Description = "传送到一面墙对面的房间",
        BookOfVirtues = "脆弱的金色火焰",
        TouhouCharacter = "霍青娥"
    },
    [Collectibles.D2147483647.Item] = {
        Name = "2147483647面骰",
        Description = "可以在拥有任何充能时使用#变形为任何主动道具，继承充能#使用变形后的道具后，变回2147483647面骰，并具有剩余充能#!!! 使用一次性主动后消失#!!! 如果变形为2147483647面骰，再次使用后会将玩家传送到错误房并消失",
        BookOfVirtues = "无",
        TouhouCharacter = "二岩{{ERROR}}藏"
    },
    [Collectibles.TheInfamies.Item] = {
        Name = "耻辱一族",
        Description = "清理房间后切换形态：#↑ 喜：+0.3速度#↑ 怒: +2伤害#↑ 哀: +1射速#↑ 惧: +1幸运#清理房间后有几率掉落扑克牌#与{{Collectible" ..
            CollectibleType.COLLECTIBLE_INFAMY .. "}}恶名昭彰，{{Collectible" ..
            CollectibleType.COLLECTIBLE_ISAACS_HEART .. "}}以撒的心脏和心脏假面敌人具有协同效应",
        TouhouCharacter = "秦心"
    },
    [Collectibles.EmptyBook.Item] = {
        Name = "空白书本",
        Description = "选择三个效果，并且生成一个成书，它具有你选择的所有三个效果#!!! 如果再次使用空白书本，则新的效果会覆盖之前所有成书的效果",
        BookOfVirtues = "无",
        TouhouCharacter = "本居小铃"
    },
    [Collectibles.EmptyBook.Item] = {
        Name = "空白书本",
        Description = "选择三个效果，并且生成一个成书，它具有你选择的所有三个效果#!!! 如果再次使用空白书本，则新的效果会覆盖之前所有成书的效果",
        BookOfVirtues = "无",
        TouhouCharacter = "本居小铃"
    },
    [Collectibles.EmptyBook.Item] = {
        Name = "空白书本",
        Description = "选择三个效果，并且生成一个成书，它具有你选择的所有三个效果#!!! 如果再次使用空白书本，则新的效果会覆盖之前所有成书的效果",
        BookOfVirtues = "无",
        TouhouCharacter = "本居小铃"
    },

    [Collectibles.SekibankisHead.Item] = {
        Name = "赤蛮奇的头",
        Description = "环绕物#每4帧造成7点接触伤害#每11帧发射造成1.75伤害的两道激光#与{{Collectible"..CollectibleType.COLLECTIBLE_GUILLOTINE.."}}断头台，{{Collectible"..CollectibleType.COLLECTIBLE_PINKING_SHEARS.."}}锯齿剪，{{Collectible"..CollectibleType.COLLECTIBLE_SCISSORS.."}}剪刀和{{Collectible"..CollectibleType.COLLECTIBLE_DECAP_ATTACK.."}}丢头攻击具有互动",
        TouhouCharacter = "赤蛮奇"
    },
    [Collectibles.DFlip.Item] = {
        Name = "镜像骰子",
        Description = "将道具重置成另一个，或者重置回来#将本房间内的塔罗牌变为反转版本#!!! 部分道具的配对是固定的",
        BookOfVirtues = "摧毁所有本道具的灵火，或者生成3个",
        TouhouCharacter = "鬼人正邪"
    },
    [Collectibles.MiracleMallet.Item] = {
        Name = "万宝槌",
        Description = "!!! 一次性使用 !!!#将本房间内的所有道具重置为品质4道具#!!! 每重置一个道具，获得3颗碎心",
        BookOfVirtues = "点金眼泪",
        TouhouCharacter = "少名针妙丸"
    },

    [Collectibles.ViciousCurse.Item] = {
        Name = "恶毒的诅咒",
        Description = "获得{{Collectible" .. CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE ..
            "}}达摩克里斯之剑#对以撒造成一颗心的伤害#{{Collectible" ..
            CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE .. "}}达摩克里斯之剑的更新速率翻倍",
        TouhouCharacter = "稀神探女"
    },
    [Collectibles.PureFury.Item] = {
        Name = "纯粹的愤怒",
        Description = "↑ 伤害x150%",
        TouhouCharacter = "纯狐"
    },

    [Collectibles.DadsShares.Item] = {
        Name = "爸爸的股票",
        Description = "清理房间后，生成一个钱币#受到伤害时，失去五个钱币#自伤不触发该效果",
        TouhouCharacter = "依神女苑"
    },
    [Collectibles.MomsIOU.Item] = {
        Name = "妈妈的欠条",
        Description = "↓-3幸运#在商店中只卖1硬币#充满以撒的钱币，直到上限#每层支付本金20%的钱币，用于偿还20%利息的债务#还清债务后，欠条消失",
        TouhouCharacter = "依神紫苑"
    },

    [Collectibles.GolemOfIsaac.Item] = {
        Name = "以撒魔像",
        Description = "魔像跟班，会自动与敌人战斗，帮你按下按钮并打开陷阱箱#伤害和射速随着楼层的增加而增加",
        TouhouCharacter = "矢田寺成美"
    },


    [Collectibles.KiketsuBlackmail.Item] = {
        Name = "鬼杰组的要挟",
        Description = "恐惧周围敌人#魅惑更远范围内的敌人",
        TouhouCharacter = "吉吊八千慧"
    },

    [Collectibles.Hunger.Item] = {
        Name = "饥饿",
        Description = "获得饥饿值系统#以撒在移动时失去饥饿值#大于9时受到治疗#大于8时属性提升#小于3时属性下降，并吞下饰品#为0时不断受到伤害#怪物会掉落食物补给#食物道具会恢复饥饿值",
        TouhouCharacter = "饕餮尤魔"
    },

    
    [Collectibles.YamawarosCrate.Item] = {
        Name = "山童的木箱",
        Description = "提供储存道具和饰品的空间#可以丢弃道具和饰品#可以被{{Collectible"..CollectibleType.COLLECTIBLE_CAR_BATTERY.."}}车载电池、{{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES.."}}美德之书和犹大的{{Collectible"..CollectibleType.COLLECTIBLE_BIRTHRIGHT.."}}长子权扩容",
        BookOfVirtues = "+2空间#可以使用蓝色卷轴传送到初始房间",
        BookOfBelial = "+2空间#可以使用红色卷轴重置该房间道具，每房间只能用一次",
        TouhouCharacter = "山城高龄"
    },
    [Collectibles.FoxInTube.Item] = {
        Name = "管中狐",
        Description = "某些情况下提供帮助#!!! 如果你接受她的帮助，你会在之后付出代价#她生成的玻璃瓶可以被眼泪打碎",
        TouhouCharacter = "菅牧典"
    },
    [Collectibles.DaitenguTelescope.Item] = {
        Name = "大天狗望远镜",
        Description = "进入新层后有几率在随机房间降下流星，并生成一个星象房道具#如果玩家不进入宝箱房，概率会提高，并在降下流星后回到1%#{{Trinket" ..
            TrinketType.TRINKET_TELESCOPE_LENS .. "}}望远镜片，{{Collectible" ..
            CollectibleType.COLLECTIBLE_MAGIC_8_BALL .. "}}魔法8号球和{{Collectible" ..
            CollectibleType.COLLECTIBLE_CRYSTAL_BALL .. "}}水晶球会增加概率",
        TouhouCharacter = "饭纲丸龙"
    },
    [Collectibles.ExchangeTicket.Item] = {
        Name = "交易所门票",
        Description = "将玩家传送到交易所交易道具#!!! 重新进入后所有内容都会被刷新",
        BookOfVirtues = "生成的灵火能被用作绿宝石",
        TouhouCharacter = "天弓千亦"
    },
    [Collectibles.CurseOfCentipede.Item] = {
        Name = "百足的诅咒",
        Description = "变为{{Collectible" .. CollectibleType.COLLECTIBLE_MUTANT_SPIDER ..
            "}}突变蜘蛛，{{Collectible" .. CollectibleType.COLLECTIBLE_BELLY_BUTTON .. "}}肚脐，{{Collectible" ..
            CollectibleType.COLLECTIBLE_POLYDACTYLY .. "}}多指症，{{Collectible" ..
            CollectibleType.COLLECTIBLE_SCHOOLBAG .. "}}书包，{{Collectible" ..
            CollectibleType.COLLECTIBLE_LUCKY_FOOT ..
            "}}幸运脚#如果玩家是腐化以撒，拿不下的道具会掉在地上",
        TouhouCharacter = "姬虫百百世"
    },

    [Collectibles.DreamSoul.Item] = {
        Name = "梦魂",
        Description = "只会生成在回溯时的地下室I层的宝箱房内#移除妈妈房间的门，然后在以撒的房间生成一个通往梦境世界的垫子",
        TouhouCharacter = "哆来咪·苏伊特"
    }
}

local EmptyBook= Collectibles.EmptyBook;
EIDInfo.KosuzuDescriptions = {
    Actives = {
        [EmptyBook.Sizes.SMALL] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "本房间内x1.25伤害",
            [EmptyBook.ActiveEffects.PRAYING] = "恢复半颗红心",
            [EmptyBook.ActiveEffects.COLLECTION] = "有50%的几率生成一枚钱币",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "对所有怪物造成20点伤害",
            [EmptyBook.ActiveEffects.PROTECTION] = "获得3秒护盾",
            [EmptyBook.ActiveEffects.FAMILIARS] = "在本房间内生成1个来自{{Collectible"..CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION.."}}恶魔受胎的跟班", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "重置所有怪物",
        },
        
        [EmptyBook.Sizes.MEDIUM] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "本房间内x1.5伤害",
            [EmptyBook.ActiveEffects.PRAYING] = "获得半颗魂心",
            [EmptyBook.ActiveEffects.COLLECTION] = "随机生成钱币、钥匙、炸弹或心",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "对所有怪物造成60点伤害",
            [EmptyBook.ActiveEffects.PROTECTION] = "获得10秒护盾",
            [EmptyBook.ActiveEffects.FAMILIARS] = "在本房间内生成3个来自{{Collectible"..CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION.."}}恶魔受胎的跟班", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "重置本房间",
        },
        
        [EmptyBook.Sizes.LARGE] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "本房间内x2伤害",
            [EmptyBook.ActiveEffects.PRAYING] = "获得永恒之心",
            [EmptyBook.ActiveEffects.COLLECTION] = "生成钱币、钥匙、炸弹和心各一个",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "对所有怪物造成180点伤害",
            [EmptyBook.ActiveEffects.PROTECTION] = "获得30秒护盾",
            [EmptyBook.ActiveEffects.FAMILIARS] = "在本房间内生成6个来自{{Collectible"..CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION.."}}恶魔受胎的跟班", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "重置本房间内的道具",
        },
    },
    Passives = {
        [EmptyBook.PassiveEffects.GOODWILLED] = "持有时，天使房转换率+10%",
        [EmptyBook.PassiveEffects.WISE] = "持有时，驱除未知、盲目、迷失诅咒",
        [EmptyBook.PassiveEffects.PRECISE] = "持有时，获得{{Collectible"..CollectibleType.COLLECTIBLE_COMPASS.."}}指南针效果",
        [EmptyBook.PassiveEffects.MEAN] = "持有时，+2直接伤害",
        [EmptyBook.PassiveEffects.CLEAR] = "持有时，+0.15速度",
        [EmptyBook.PassiveEffects.SELFLESS] = "持有时，受伤后为主动道具充能1格", 
        [EmptyBook.PassiveEffects.INNOVATIVE] = "使用后生成灵火",
    }
}

EIDInfo.Trinkets = {
    [Trinkets.FrozenFrog.Trinket] = {
        Name = "冻青蛙",
        Description = "冻结玩家接触到的非BOSS敌人",
        TouhouCharacter = "琪露诺"
    },
    [Trinkets.AromaticFlower.Trinket] = {
        Name = "常樱之花",
        Description = "玩家死亡后复活，并具有心之容器一半的红心，常樱之花消失",
        GoldenInfo = {findReplace = true},
        GoldenEffect = {"心之容器一半的红心", "满红心", "满红心和2颗魂心"},
        TouhouCharacter = "莉莉霍瓦特"
    },
    [Trinkets.GlassesOfKnowledge.Trinket] = {
        Name = "博学眼镜",
        Description = "以撒每有一种道具：#↑ +0.03速度#↑ +0.03伤害#↑ +0.02射速#↑ +0.038射程",
        GoldenInfo = {t={0.03, 0.03, 0.02, 0.038}},
        TouhouCharacter = "森近霖之助"
    },
    [Trinkets.CorrodedDoll.Trinket] = {
        Name = "腐蚀的人偶",
        Description = "以撒每7帧流下绿色水迹，每帧造成20%的玩家伤害，存在一秒",
        GoldenInfo = 20,
        TouhouCharacter = "梅蒂欣·梅兰可莉"
    },
    [Trinkets.LionStatue.Trinket] = {
        Name = "狮子雕像",
        Description = "在有天使雕像的房间额外生成1座天使雕像",
        GoldenInfo = 1,
        TouhouCharacter = "高丽野阿{{ERROR}}"
    },
    [Trinkets.FortuneCatPaw.Trinket] = {
        Name = "招财猫爪",
        Description = "敌人死亡后有25%的几率掉落1颗临时钱币#BOSS总会掉落3颗临时钱币",
        GoldenInfo = {t={1, 3}},
        TouhouCharacter = "豪德寺三花"
    },
    [Trinkets.MermanShell.Trinket] = {
        Name = "鱼人贝壳",
        Description = "在被水淹没的房间获得：#↑ +2攻击力#↑ +1射速#↑ +0.15速度#进入下一层后，淹没20%的房间",
        GoldenInfo = {t={20}},
        TouhouCharacter= "若鹭姬"
    }
};
EIDInfo.Birthrights = {
    [Players.Eika.Type] = {
        Description = "可以堆叠20个石头",
        PlayerName = "璎花"
    },
    [Players.EikaB.Type] = {
        Description = "血骷髅会再生血量",
        PlayerName = "堕化璎花"
    },
    [Players.Satori.Type] = {
        Description = "在进入房间后，魅惑三个随机小怪5分钟",
        PlayerName = "觉"
    },
    [Players.SatoriB.Type] = {
        Description = "↑ 速度+最大速度提升#速度大于等于1时碾压会造成爆炸",
        PlayerName = "堕化觉"
    }
}

EIDInfo.CollectibleTransformations = {

    [Collectibles.Grimoire.Item] = "书虫套装",
    [Collectibles.BookOfYears.Item] = "书虫套装",
    [Collectibles.EmptyBook.Item] = "书虫套装",

    [Collectibles.Koakuma.Item] = "连体套装",
    [Collectibles.ChenBaby.Item] = "连体套装",

    [Collectibles.MomsIOU.Item] = "妈妈套装",

    [CollectibleType.COLLECTIBLE_METRONOME] = "音乐家套装",
    [CollectibleType.COLLECTIBLE_PLUM_FLUTE] = "音乐家套装",
    [Collectibles.MelancholicViolin.Item] = "音乐家套装",
    [Collectibles.ManiacTrumpet.Item] = "音乐家套装",
    [Collectibles.IllusionaryKeyboard.Item] = "音乐家套装",
    [Collectibles.DeletedErhu.Item] = "音乐家套装",
    [Collectibles.SongOfNightbird.Item] = "音乐家套装",
    [Collectibles.MountainEar.Item] = "音乐家套装",

    [Collectibles.JarOfFireflies.Item] = 3,

    [Collectibles.GourdShroom.Item] = "蘑菇套装"
}

EIDInfo.LunaticDescs = {
    Collectibles = {
        [Collectibles.DarkRibbon.Item] = "增加的伤害倍率变为20%",
        [Collectibles.DYSSpring.Item] = "妖精只会治疗一颗红心和一颗魂心",
        [Collectibles.MaidSuit.Item] = "只能时间停止2秒钟，世界卡改为在击败BOSS后生成。",
        [Collectibles.VampireTooth.Item] = "心掉落率减少为2.5%",
        [Collectibles.Roukanken.Item] = "杀死敌人不回复充能",
        [Collectibles.FanOfTheDead.Item] = "生命上限为20",
        [Collectibles.OneOfNineTails.Item] = "在达到上限9之后不再生成道具",
        [Collectibles.Starseeker.Item] = "选项只有两个",
        [Collectibles.BookOfYears.Item] = "有30%的几率不生成道具",
        [Collectibles.TenguCamera.Item] = "石化时间缩短到4秒",
        [Collectibles.RuneSword.Item] = "马骑符文地下室生成概率降低为每个符文+50%",
        [Collectibles.Pagota.Item] = "对怪物不再有点金效果",
        [Collectibles.ZombieInfestation.Item] = "怪物只有50%的几率生成友方复制",
        [Collectibles.D2147483647.Item] = "需要2充能转换成为主动道具，并且排除了{{Collectible" ..
            CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE .. "}}死亡证明",
        [Collectibles.TheInfamies.Item] = "不再魅惑BOSS",
        [Collectibles.Hunger.Item] = "怪物不再掉落食物",
    },
    Trinkets = {
        [Trinkets.FortuneCatPaw.Trinket] = "boss掉落钱币的概率变为60%",
    }
}
return EIDInfo;
