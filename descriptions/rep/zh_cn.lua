------------------------------------------------------------------
-----  Basic English descriptions based on Platinumgod.co.uk -----
------------------------------------------------------------------
-- FORMAT: Item ID | Name| Description
-- '#' = starts new line of text
-- Special character markup:
-- ↑ = Up Arrow   |  ↓ = Down Arrow    | ! = Warning
local Collectibles = THI.Collectibles;
local Trinkets = THI.Trinkets;
local Cards = THI.Cards;
local Players = THI.Players;

local EIDInfo = {};

EIDInfo.Entries = {
    ["Lunatic"] = "{{ColorPurple}}疯狂模式{{CR}}："
}

EIDInfo.Transformations = {
    ReverieMusician = "音乐家套装",
}

EIDInfo.Collectibles = {


    -- TH6
    [Collectibles.YinYangOrb.Item] = {
        Name = "阴阳玉",
        Description = "扔出一个反弹的阴阳玉"..
        "#造成20点碰撞伤害",
        BookOfVirtues = "阴阳玉火焰"
    },
    [Collectibles.MarisasBroom.Item] = {
        Name = "魔理沙的扫帚",
        Description = "飞行"..
        "#每有一种蘑菇道具："..
        "#↑  {{Speed}}+0.3移速"..
        "#↑  {{Tears}}+0.5射速"..
        "#↑  {{Damage}}+1伤害"
    },
    [Collectibles.DarkRibbon.Item] = {
        Name = "黑暗缎带",
        Description = "角色具有一个伤害光环，每秒造成10.71点伤害"..
        "#↑  {{Damage}}站在光环中+50%伤害"
    },
    [Collectibles.DYSSpring.Item] = {
        Name = "大妖精之泉",
        Description = "{{SoulHeart}} +2魂心"..
        "#{{Heart}} 回满血量"..
        "#{{Battery}} 回满充能"..
        "#有10%的几率将心转化为妖精"..
        "#妖精能够{{Heart}}回满血量且给予1颗{{SoulHeart}}魂心"
    },
    [Collectibles.DragonBadge.Item] = {
        Name = "虹龙徽章",
        Description = "向敌人冲刺"..
        "#冲刺时无敌"..
        "#击中敌人时释放拳弹并获得额外无敌时间",
        BookOfVirtues = "拳弹"
    },
    [Collectibles.Koakuma.Item] = {
        Name = "小恶魔宝宝",
        Description = "大子弹跟班"..
        "#每颗眼泪造成3点伤害"..
        "#与{{Bookworm}}书虫套装和{{Collectible" ..
            Collectibles.Grimoire.Item .. "}}帕秋莉的魔导书具有协同效应"
    },
    [Collectibles.Grimoire.Item] = {
        Name = "帕秋莉的魔导书",
        Description = "在本层内获得随机眼泪特效"..
        "#特效：跟踪，魅惑，燃烧，减速，中毒，磁化，石头"..
        "#如果所有7个效果都已获得，传送到错误房",
        BookOfVirtues = "七曜子弹/错误子弹"
    },
    [Collectibles.MaidSuit.Item] = {
        Name = "女仆服装",
        Description = "{{Card21}} 生成XXI-世界"..
        "#进入房间后暂停所有敌人"..
        "#{{Card21}} XXI-世界具有时停飞刀效果"..
        "#{{Card21}} 清理房间后有几率生成XXI-世界"
    },
    [Collectibles.VampireTooth.Item] = {
        Name = "吸血鬼之牙",
        Description = "↑  {{Damage}}+1伤害"..
        "#↑  {{Luck}}+2运气"..
        "#飞行"..
        "#{{Card20}} !!! XIX-太阳会伤害角色的所有红心"..
        "#{{Card19}} XVIII-月亮会传送到{{UltraSecretRoom}}究极隐藏"
    },
    [Collectibles.Destruction.Item] = {
        Name = "毁灭",
        Description = "召唤一个会爆炸和碎成碎片的陨石"..
        "#本房间内，持续在角色的位置掉落陨石",
        BookOfVirtues = "燃烧子弹，火焰熄灭后爆炸"
    },
    [Collectibles.DeletedErhu.Item] = {
        Name = "被删除的二胡",
        Description = "!!! 一次性 !!!"..
        "#移除本房间内的所有敌人和障碍物"..
        "#被移除的敌人和障碍物在本局游戏中不再出现",
        BookOfVirtues = "错误火焰"
    },



    -- TH7
    [Collectibles.FrozenSakura.Item] = {
        Name = "冻结的樱花",
        Description = "角色具有一个伤害光环，每秒造成4.3点伤害"..
        "#{{Slow}} 减速光环内的敌人和子弹"..
        "#{{Freezing}} 冻结被光环杀死的敌人"
    },
    [Collectibles.ChenBaby.Item] = {
        Name = "橙宝宝",
        Description = "向前冲刺的跟班"..
        "#造成3.5点接触伤害，并飞向另一个最近的敌人"..
        "#{{Collectible"..Collectibles.OneOfNineTails.Item.."}} 九尾之尾会翻倍其攻击力"
    },
    [Collectibles.ShanghaiDoll.Item] = {
        Name = "上海人偶",
        Description = "环绕物"..
        "#向接近角色的敌人冲刺并造成3.5点伤害"
    },
    [Collectibles.MelancholicViolin.Item] = {
        Name = "忧郁提琴",
        Description = "生成一个存在10秒的小提琴"..
        "#↑ 范围内{{Tears}}+5射速"..
        "#{{Slow}} 减速范围内的敌人",
        BookOfVirtues = "减速泪弹"
    },
    [Collectibles.ManiacTrumpet.Item] = {
        Name = "狂躁小号",
        Description = "生成一个存在10秒的小号"..
        "#↑ 范围内{{Damage}}+50%伤害"..
        "#伤害范围内的敌人",
        BookOfVirtues = "混乱泪弹"
    },
    [Collectibles.IllusionaryKeyboard.Item] = {
        Name = "幻想键盘",
        Description = "生成一个存在10秒的键盘"..
        "#↑ 范围内{{Speed}}+1移速"..
        "#消除范围内的子弹",
        BookOfVirtues = "魅惑泪弹"
    },
    [Collectibles.Roukanken.Item] = {
        Name = "楼观剑",
        Description = "在18秒内使用剑斩击，每击造成5倍{{Damage}}角色伤害，并摧毁障碍物"..
        "#再次使用会向移动方向冲刺，对路径上的敌人造成2倍{{Damage}}角色伤害"..
        "#{{Battery}} 使用冲刺杀敌会回复充能",
        BookOfVirtues = "近战火焰，能够摧毁障碍物"
    },
    [Collectibles.FanOfTheDead.Item] = {
        Name = "死者之扇",
        Description = "飞行"..
        "#幽灵眼泪"..
        "#将所有{{EmptyHeart}}心之容器和{{SoulHeart}}魂心转化为额外生命"
    },
    [Collectibles.FriedTofu.Item] = {
        Name = "油炸豆腐",
        Description = "↑  {{Heart}}+1心之容器"..
        "#{{Heart}} 治疗1红心",
        BingeEater = "↑  {{Range}}+1.5射程"..
        "#↑  {{Luck}}+1.0运气"..
        "#↓  {{Speed}}-0.03移速"
    },
    [Collectibles.OneOfNineTails.Item] = {
        Name = "九尾之尾",
        Description = "生成一个宝宝商店的道具"..
        "#进入新的一层后生成宝宝商店的道具"..
        "#↑ 每有一个跟班，{{Damage}}伤害提升"..
        "#在拥有9个跟班时伤害达到最大值，为150%"..
        "#{{Collectible"..Collectibles.ChenBaby.Item.."}} 橙宝宝算作三个跟班"
    },
    [Collectibles.Gap.Item] = {
        Name = "隙间",
        Description = "生成连接所有房间的传送地板"..
        "#在地板上使用隙间以使用地板"..
        "#{{UltraSecretRoom}} 包括究极隐藏",
        BookOfVirtues = "传送泪弹"
    },


    -- Secret Sealing
    [Collectibles.Starseeker.Item] = {
        Name = "寻星者",
        Description = "进入有道具的房间后生成三个水晶球"..
        "#拾取水晶球后其他两个消失"..
        "#下一个该房间类型的道具被选中的道具替换"..
        "#每有一个道具便进行一轮选择"
    },
    [Collectibles.Pathseeker.Item] = {
        Name = "寻道者",
        Description = "每层开始时，在起始房间生成显示本层所有房间的地板"..
        "#{{Collectible"..Collectibles.Gap.Item.."}} 可以使用隙间进行传送"
    },


    -- TH7.5
    [Collectibles.GourdShroom.Item] = {
        Name = "葫芦菇",
        Description = "受伤害后转换疏密形态"..
        "#{{ColorOrange}}密形态：{{CR}}"..
        "#↑  {{Damage}}伤害x135%"..
        "#↑  {{Range}}射程+3"..
        "#{{Blank}} 大小x1.5，可以踩碎石头"..
        "#{{ColorOrange}}疏形态：{{CR}}"..
        "#↑  {{Tears}}射速x150%"..
        "#↑  {{Speed}}移速+0.5"..
        "#{{Blank}} 大小x0.75，生成5个迷你以撒"
    },



    -- TH8
    [Collectibles.JarOfFireflies.Item] = {
        Name = "萤火虫罐",
        Description = "放出12个友方着火苍蝇"..
        "#着火苍蝇会扑向敌人，接触时爆炸并造成等同于角色伤害的伤害"..
        "#{{CurseDarkness}} 清除黑暗诅咒",
        BookOfVirtues = "3个熄灭后生成着火苍蝇的火焰"
    },
    [Collectibles.SongOfNightbird.Item] = {
        Name = "夜雀之歌",
        Description = "{{CurseDarkness}} 永久具有黑暗诅咒"..
        "#{{Confusion}} 远离角色的敌人被混乱，并且受到的伤害增加50%"
    },
    [Collectibles.BookOfYears.Item] = {
        Name = "岁月史书",
        Description = "移除品质最低的一个被动道具"..
        "#生成一个随机道具",
        BookOfVirtues = "熄灭后生成{{Collectible"..CollectibleType.COLLECTIBLE_MISSING_PAGE_2.."}}遗失书页2"
    },
    [Collectibles.RabbitTrap.Item] = {
        Name = "兔之陷阱",
        Description = "↑  {{Luck}}+1运气"..
        "#进入有敌人的房间后生成陷阱"..
        "#陷阱立即杀死地面怪物，并且每秒对Boss造成45点伤害"
    },
    [Collectibles.Illusion.Item] = {
        Name = "幻象",
        Description = "在角色中等距离外生成四个幻象"..
        "#每秒造成角色伤害2.14倍的接触伤害"..
        "#会朝射击方向发射血泪，伤害3.5"
    },
    [Collectibles.PeerlessElixir.Item] = {
        Name = "无双之药",
        Description = "在本层中："..
        "#↑  {{Damage}}+0.6伤害"..
        "#↑  {{Tears}}+0.6射速"..
        "#↑  {{Speed}}+0.3移速"..
        "#!!! 本层第四次使用后，角色爆炸并死亡",
        BookOfVirtues = "强力绿色火焰，熄灭后爆炸"
    },
    [Collectibles.DragonNeckJewel.Item] = {
        Name = "龙颈之玉",
        Description = "每隔3秒在角色最近的敌人处降下圣光"..
        "#圣光会产生5颗眼泪，每颗造成3.5点伤害"
    },
    [Collectibles.BuddhasBowl.Item] = {
        Name = "佛御石之钵",
        Description = "受伤后防止下一次伤害"
    },
    [Collectibles.RobeOfFirerat.Item] = {
        Name = "火鼠的皮衣",
        Description = "生成一个火焰环绕物"..
        "#穿过火焰的子弹会变成新的火焰"..
        "#免疫火焰伤害"
    },
    [Collectibles.SwallowsShell.Item] = {
        Name = "燕的子安贝",
        Description = "进入新层后生成一个{{AngelRoom}}天使房道具"..
        "#每有一个{{Conjoined}}连体套装道具，生成一颗魂心"..
        "#!!! 受伤后消失"
    },
    [Collectibles.JeweledBranch.Item] = {
        Name = "蓬莱玉枝",
        Description = "在角色周围形成眼泪环"..
        "#如果眼泪数量达到上限5，其中一个会脱离环并向最近的敌人飞去"
    },
    [Collectibles.AshOfPhoenix.Item] = {
        Name = "不死鸟灰烬",
        Description = "角色死后变为灰烬，并生成四条火浪"..
        "#如果灰烬在2秒内未受到任何伤害，复活角色并再次生成火浪"..
        "#!!! 自伤不触发该效果"
    },

    -- TH9
    [Collectibles.TenguCamera.Item] = {
        Name = "天狗相机",
        Description = "持有时显示扇形范围"..
        "#使用后石化范围内的敌人并消除子弹，造成5点伤害"..
        "#根据拍到的敌人和子弹数量生成分数和奖励："..
        "#{{Blank}} 10: 1{{Coin}}硬币 12: 1{{Key}}钥匙"..
        "#{{Blank}} 16: 1{{Bomb}}炸弹 22: 1{{Pill}}药丸"..
        "#{{Blank}} 30: 1{{Card}}卡牌 40: 1{{Trinket}}饰品"..
        "#{{Blank}} 52: 1{{SoulHeart}}魂心"..
        "#{{Blank}} 66: {{Collectible"..CollectibleType.COLLECTIBLE_NEGATIVE.."}}底片"..
        "#{{Blank}} 82: {{Collectible"..CollectibleType.COLLECTIBLE_TORN_PHOTO.."}}撕裂的照片"..
        "#{{Blank}} 100: {{Collectible"..CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE.."}}死亡证明",
        BookOfVirtues = "将敌弹变为无法发射眼泪的黑色火焰"
    },
    [Collectibles.SunflowerPot.Item] = {
        Name = "向日葵盆栽",
        Description = "角色头上的向日葵跟班"..
        "#在清理房间后，生成一个掉落物或道具"..
        "#!!! 角色受伤后，向日葵死亡，之后爆炸并对角色造成额外一颗心的伤害"..
        "#下一层复活"..
        "#{{Collectible" ..
            CollectibleType.COLLECTIBLE_BFFS .. "}} 好朋友一辈子！会让向日葵改为掉落两个"
    },
    [Collectibles.ContinueArcade.Item] = {
        Name = "继续？",
        Description = "{{Coin}} +3钱币"..
        "#角色死后支付3{{Coin}}钱币在本房间内复活"..
        "#复活后所有红心回满"..
        "#!!! 每次复活，所需的钱币数量变为三倍"
    },
    [Collectibles.RodOfRemorse.Item] = {
        Name = "悔悟棒",
        Description = "受到一颗心的伤害（优先扣除红心），并触发一次{{SacrificeRoom}}献祭房的效果"..
        "#献祭次数与任何献祭房无关，并会在进入下一层后重置",
        BookOfVirtues = "熄灭后有25%的几率掉落红心"
    },

    [Collectibles.IsaacsLastWills.Item] = {
        Name = "以撒的遗书",
        Description = "!!! 一次性 !!!"..
        "#将当前房间中的所有道具和饰品送到下一局"..
        "#!!! 在挑战或种子局中不起作用"..
        "#!!! 如果MOD被关闭，没有效果，直到MOD被再次开启",
        BookOfVirtues = "下一局开始时获得一圈强力火焰"
    },
    [Collectibles.SunnyFairy.Item] = {
        Name = "太阳妖精",
        Description = "每层都会休眠的跟班"..
        "#进入{{BossRoom}}Boss房或使用{{Card20}}XIX-太阳后苏醒，并生成三颗{{Heart}}红心"..
        "#苏醒后每秒发射3颗4点伤害的燃烧泪弹"..
        "#如果玩家拥有所有三只{{Collectible"..Collectibles.SunnyFairy.Item.."}}{{Collectible"..Collectibles.LunarFairy.Item.."}}{{Collectible"..Collectibles.StarFairy.Item.."}}光之妖精，同时唤醒她们，并且伤害变为三倍"
    },
    [Collectibles.LunarFairy.Item] = {
        Name = "月亮妖精",
        Description = "每层都会休眠的跟班"..
        "#进入{{SecretRoom}}隐藏房，{{SuperSecretRoom}}超级隐藏房或{{UltraSecretRoom}}究极隐藏房后苏醒，并生成两颗{{Bomb}}炸弹"..
        "#苏醒后每秒发射3颗3点伤害的反弹泪弹"..
        "#如果玩家拥有所有三只{{Collectible"..Collectibles.SunnyFairy.Item.."}}{{Collectible"..Collectibles.LunarFairy.Item.."}}{{Collectible"..Collectibles.StarFairy.Item.."}}光之妖精，同时唤醒她们，并且伤害变为三倍"
    },
    [Collectibles.StarFairy.Item] = {
        Name = "星星妖精",
        Description = "每层都会休眠的跟班"..
        "#进入{{TreasureRoom}}宝箱房或{{Planetarium}}星象房后苏醒，并生成一把{{Key}}钥匙"..
        "#苏醒后每秒发射3颗2点伤害的跟踪泪弹"..
        "#如果玩家拥有所有三只{{Collectible"..Collectibles.SunnyFairy.Item.."}}{{Collectible"..Collectibles.LunarFairy.Item.."}}{{Collectible"..Collectibles.StarFairy.Item.."}}光之妖精，同时唤醒她们，并且伤害变为三倍"
    },


    --TH10
    [Collectibles.LeafShield.Item] = {
        Name = "飞叶护盾",
        Description = "每三秒生成飞叶护盾"..
        "#每7帧造成4点伤害，并阻挡所有敌弹"..
        "#按下射击键会将护盾发射出去"
    },
    [Collectibles.BakedSweetPotato.Item] = {
        Name = "烤红薯",
        Description = "↑  {{Heart}}+1心之容器"..
        "#{{Heart}} 治疗1红心"..
        "#↑  {{Damage}}+5伤害，并在2分钟内衰减完毕"
    },
    [Collectibles.BrokenAmulet.Item] = {
        Name = "破碎的护身符",
        Description = "↓  {{Luck}}-3运气"..
        "#眼泪具有黑色光圈，光圈中的敌人每秒受到15次伤害"..
        "#角色运气越低，光圈越大，伤害越高"..
        "#{{Luck}} 0运气时20%角色伤害"..
        "#{{Luck}} -5运气时80%角色伤害"
    },
    [Collectibles.ExtendingArm.Item] = {
        Name = "延展手臂",
        Description = "向一个方向发射钩爪"..
        "#击中的敌人会被石化，并且被拉到角色面前"..
        "#击中障碍物后，将角色拉到障碍物前方"..
        "#击中掉落物后，将其拉到角色面前"..
        "#直到拉取结束，角色无敌",
        BookOfVirtues = "伸长时产生停止的临时绿色火焰"
    },
    [Collectibles.WolfEye.Item] = {
        Name = "狼眼",
        Description = "↑  {{Damage}}+0.5伤害"..
        "#显示所有地图边缘的房间"..
        "#提升敌弹可见度"
    },
    [Collectibles.Benediction.Item] = {
        Name = "祈愿",
        Description = "可以在任何充能时使用"..
        "#根据当前充能获得一个{{AngelRoom}}天使房道具，仅持续本层："..
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
        BookOfVirtues = "灵火血量根据充能而定"
    },
    [Collectibles.Onbashira.Item] = {
        Name = "御柱",
        Description = "从天召唤一个御柱，砸毁周围所有障碍物和敌人，并产生裂地波"..
        "#御柱会存在8秒，期间会使用圣光攻击附近所有敌人，每击2点伤害"..
        "#{{Collectible"..Collectibles.YoungNativeGod.Item.."}} 范围内的年幼土著神伤害变为三倍",
        BookOfVirtues = "灵火有10%的几率射出圣光泪弹"
    },
    [Collectibles.YoungNativeGod.Item] = {
        Name = "年幼土著神",
        Description = "地下移动的蛇跟班"..
        "#{{Poison}} 会撕咬敌人，造成35点伤害，并使其中毒"..
        "#摧毁行进路径上的所有石头，并帮助玩家找到隐藏石头和{{LadderRoom}}地下室"
    },

    
    [Collectibles.GeographicChain.Item] = {
        Name = "山海铁链",
        Description = "↑  {{Luck}}持有时+2运气"..
        "#使用后，摧毁所有石头、锁、铁块、蜘蛛网和柱子，填上所有深坑"..
        "#杀死所有无敌的机关，或者拥有无敌外壳的怪物",
        BookOfVirtues = "石头灵火，发射石头"
    },
    [Collectibles.RuneSword.Item] = {
        Name = "符文佩剑",
        Description = "拿起时，生成一个{{Rune}}随机符文"..
        "#将持有的{{Rune}}符文镶嵌在该道具上，变为该道具的被动效果"..
        "#不持有符文时，改为获得一颗{{Rune}}符文",
        BookOfVirtues = "符文灵火"
    },
    [Collectibles.Escape.Item] = {
        Name = "逃跑",
        Description = "↑  {{Speed}}+0.15移速"..
        "#受伤或者{{Collectible"..CollectibleType.COLLECTIBLE_HOLY_MANTLE.."}}神圣斗篷破碎后，本房间↑{{Speed}}+0.15移速，并且打开所有未上锁的门"
    },
    [Collectibles.Keystone.Item] = {
        Name = "要石",
        Description = "{{Key}} 拿起后+3钥匙"..
        "#使用后，释放一场持续4秒的地震，摧毁石头和门，并从天花板落下石头"..
        "#对所有地面怪物造成伤害，数值约为每秒11.4%当前生命值",
        BookOfVirtues = "石头灵火，发射石头"
    },
    [Collectibles.AngelsRaiment.Item] = {
        Name = "天之羽衣",
        Description = "飞行"..
        "#受伤后触发{{Collectible"..CollectibleType.COLLECTIBLE_CRACK_THE_SKY.."}}撕裂苍穹的效果"
    },


    
    -- TH11
    [Collectibles.BucketOfWisps.Item] = {
        Name = "鬼火桶",
        Description = "怪物死亡后获得其灵魂"..
        "#使用后，花费8颗灵魂生产一团灵火"..
        "#灵火的血量和眼泪伤害基于怪物的最大血量",
        BookOfVirtues = "翻倍生产的灵火"
    },
    [Collectibles.PlagueLord.Item] = {
        Name = "瘟疫领主",
        Description = "{{Poison}} 使周围敌人中毒"..
        "#{{Poison}} 中毒的敌人死亡后留下毒云"
    },
    [Collectibles.GreenEyedEnvy.Item] = {
        Name = "绿眼的嫉妒",
        Description = "进入房间后，将本房间所有非最终Boss的敌人的生命值降为40%"..
        "#在它们死亡后，生成两个具有20%生命值的小型复制"
    },
    [Collectibles.OniHorn.Item] = {
        Name = "鬼之角",
        Description = "↑  {{Damage}}+1伤害"..
        "#每当角色受到伤害："..
        "#第一次：生成一圈裂地波"..
        "#第二次：生成三圈裂地波，并爆炸"..
        "#第三次：生成全屏裂地波，并产生巨大爆炸"..
        "#第三次受伤或者进入新的房间后，受伤计数器重置"..
        "#!!! {{BloodDonationMachine}}卖血机、{{Confessional}}忏悔室和{{DemonBeggar}}乞丐不触发该效果"
    },
    [Collectibles.PsycheEye.Item] = {
        Name = "精神眼",
        Description = "眼睛跟班"..
        "#{{Charm}} 蓄力2.5秒将周围的小怪变为友方，并魅惑BOSS"..
        "#!!! 每个精神眼最多同时控制5个小怪"..
        "#按住"..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].."和射击键释放心灵震爆，杀死所有友方小怪"
    },
    [Collectibles.GuppysCorpseCart.Item] = {
        Name = "嗝屁猫的尸体推车",
        Description = "飞行"..
        "#↑  {{Speed}}+0.2移速"..
        "#以0.85移速以上的速度移动时，碾压敌人，并且不受其碰撞伤害"
    },
    [Collectibles.Technology666.Item] = {
        Name = "科技666",
        Description = "每秒额外发射一条黄色硫磺火，造成15%的角色伤害"..
        "#如果硫磺火杀死敌人，敌人爆炸，并在敌人位置爆出6条新的硫磺火激光"..
        "#爆炸不会伤到角色，并且爆出的硫磺火激光具有同样的效果"
    },
    [Collectibles.PsychoKnife.Item] = {
        Name = "疯人刀",
        Description = "处决附近的一个敌人"..
        "#会直接杀死小怪，对Boss造成大量破甲伤害，并将周围的敌人震开"..
        "#只能处决近距离的敌人。如果敌人生命值过低或处在异常状态，处决范围翻倍",
        BookOfVirtues = "黑色火焰"
    },


    --TH12
    [Collectibles.DowsingRods.Item] = {
        Name = "探宝棒",
        Description = "使部分普通石头隐藏一些物品"..
        "#发出声波探测这些石头"..
        "#距离越近声波越频繁"
    },
    [Collectibles.ScaringUmbrella.Item] = {
        Name = "惊吓唐伞",
        Description = "阻挡上方子弹"..
        "#本房间射击后不停掉落眼泪雨"..
        "#{{Fear}} 随机恐惧周围敌人"..
        "#在角色没有危险时惊吓角色"
    },
    [Collectibles.Unzan.Item] = {
        Name = "云山",
        Description = "进入有敌人的房间后，召唤云山辅助攻击"..
        "#在玩家两侧生成巨型拳头眼泪"..
        "#拳头造成(2 * 当前层)的伤害"..
        "#拳头会在房间中心相撞，对中心的怪物造成大量伤害"..
        "#清理房间后云山离开"
    },
    [Collectibles.Pagota.Item] = {
        Name = "毗沙门天的宝塔",
        Description = "!!! 一次性 !!!"..
        "#{{Coin}} 需要钱币作为充能"..
        "#将整层变为金色，并且将所有掉落物和便便变为金色版本"..
        "#点金所有敌人5秒",
        BookOfVirtues = "12个金色火焰，发射点金眼泪"
    },
    [Collectibles.SorcerersScroll.Item] = {
        Name = "魔人经卷",
        Description = "!!! 移除角色所有{{SoulHeart}}魂心（不致死）"..
        "#每移除半颗魂心："..
        "#↑  {{Damage}}+0.2攻击力"..
        "#↑  {{Tears}}+0.2射速"..
        "#↑  {{Speed}}+0.03移速"..
        "#↑  {{Range}}+0.4射程",
        BookOfVirtues = "咒文火焰，提升角色所有属性"
    },
    [Collectibles.SaucerRemote.Item] = {
        Name = "飞碟遥控器",
        Description = "生成一个吸走掉落物和道具的UFO"..
        "#摧毁UFO后生成双倍奖励"..
        "#!!! 15秒后UFO逃走",
        BookOfVirtues = "可以通过消耗3个颜色相同，或完全不同的UFO火焰来免费使用"
    },

    [Collectibles.TenguCellphone.Item] = {
        Name = "天狗手机",
        Description = "网购！"..
        "#网购货物一次只有三个，并且每个房间都不一样"..
        "#货物根据当前房间类型决定"..
        "#购买后的货物会快递到下一层"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_STEAM_SALE.."}} 可被Steam大促降价",
        BookOfVirtues = "点金泪弹"
    },
    [Collectibles.EtherealArm.Item] = {
        Name = "虚无断臂",
        Description = "!!! 无法再持有卡牌、药丸等口袋物品"..
        "#将角色的口袋物品替换为虚空之手，可以将卡牌、药丸等变形为所有道具池中的随机道具"..
        "#每层只能用三次"..
        "#标记骷髅总会掉落{{Collectible"..CollectibleType.COLLECTIBLE_TELEPORT.."}}传送！"
    },


    [Collectibles.MountainEar.Item] = {
        Name = "山谷之耳",
        Description = "11%的几率发射回声眼泪，在房间中反弹"..
        "#击中角色后消失，并且暂时提升角色攻击力"..
        "#{{Luck}} 8运气：100%"
    },
    [Collectibles.ZombieInfestation.Item] = {
        Name = "僵尸感染",
        Description = "获得时将所有{{Heart}}红心替换为{{RottenHeart}}腐心"..
        "#每当一个小怪死亡，生成一个它的友方全新复制"..
        "#该复制无法被带出房间"
    },
    [Collectibles.WarpingHairpin.Item] = {
        Name = "穿墙发簪",
        Description = "传送到一面墙对面的房间",
        BookOfVirtues = "脆弱的金色火焰"
    },
    [Collectibles.HolyThunder.Item] = {
        Name = "圣雷",
        Description = "5.88%概率发射圣雷泪弹，击中或落地后生成圣雷"..
        "#圣雷会在附近的敌人之间建立连锁激光，造成2倍的泪弹伤害"..
        "#{{Luck}} 15运气：50%"
    },
    [Collectibles.GeomanticDetector.Item] = {
        Name = "风水探测器",
        Description = "↓  {{Luck}}-3运气"..
        "#↑  {{Luck}}房间内每有一个空地，+0.05运气"..
        "#↑  {{Luck}}房间每相邻一个隐藏房，+3运气"
    },
    [Collectibles.Lightbombs.Item] = {
        Name = "圣光炸弹",
        Description = "{{Bomb}} +5炸弹"..
        "#炸弹在环形范围内生成10条圣光"
    },
    [Collectibles.D2147483647.Item] = {
        Name = "2147483647面骰",
        Description = "可以在拥有任何充能时使用"..
        "#变形为任何主动道具，继承充能"..
        "#使用变形后的道具后，变回2147483647面骰，并具有剩余充能"..
        "#!!! 使用一次性主动后消失"..
        "#!!! 如果变形为{{Collectible"..Collectibles.D2147483647.Item.."}}2147483647面骰，再次使用后会将角色传送到错误房并消失",
        BookOfVirtues = "无"
    },
    [Collectibles.EmptyBook.Item] = {
        Name = "空白书本",
        Description = "选择三个效果，并且生成一个成书，它具有你选择的所有三个效果"..
        "#!!! 如果再次使用空白书本，则新的效果会覆盖之前所有成书的效果",
        BookOfVirtues = "无"
    },
    [Collectibles.TheInfamies.Item] = {
        Name = "耻辱一族",
        Description = "清理房间后切换形态："..
        "#{{ColorOrange}}喜{{CR}}: ↑{{Speed}}+0.3移速"..
        "#{{ColorOrange}}怒{{CR}}: ↑{{Damage}}+2伤害"..
        "#{{ColorOrange}}哀{{CR}}: ↑{{Tears}}+1射速"..
        "#{{ColorOrange}}惧{{CR}}: ↑{{Luck}}+1运气"..
        "#清理房间后有几率掉落扑克牌"..
        "#与{{Collectible" ..
            CollectibleType.COLLECTIBLE_INFAMY .. "}}恶名昭彰，{{Collectible" ..
            CollectibleType.COLLECTIBLE_ISAACS_HEART .. "}}以撒的心脏和心脏假面敌人具有协同效应"
    },


    --TH14
    [Collectibles.SekibankisHead.Item] = {
        Name = "赤蛮奇的头",
        Description = "环绕物"..
        "#每秒造成52.5点接触伤害"..
        "#每11帧发射造成1.75伤害的两道激光"..
        "#与{{Collectible"..CollectibleType.COLLECTIBLE_GUILLOTINE.."}}断头台，{{Collectible"..CollectibleType.COLLECTIBLE_PINKING_SHEARS.."}}锯齿剪，{{Collectible"..CollectibleType.COLLECTIBLE_SCISSORS.."}}剪刀和{{Collectible"..CollectibleType.COLLECTIBLE_DECAP_ATTACK.."}}丢头攻击具有互动"
    },
    [Collectibles.WildFury.Item] = {
        Name = "野性狂暴",
        Description = "进入狂怒模式10秒，↑ 角色的{{Speed}}移速、{{Tears}}射速、{{Damage}}伤害和{{Range}}射程x150%"..
        "#↑ 在狂怒模式下杀死的敌人会给予角色全属性上升"..
        "#!!! 上升值取决于敌人的最大生命值",
        BookOfVirtues = "进攻性极强，但极其脆弱的灵火"
    },
    [Collectibles.ReverieMusic.Item] = {
        Name="幻想曲乐谱",
        Description = "游戏播放5首音乐后出现在第一个宝箱房内"..
        "#音乐播放时将其收集"..
        "#收集15首音乐，并击败妈妈的心后开启一个秘密入口"
    },
    [Collectibles.DFlip.Item] = {
        Name = "镜像骰子",
        Description = "将道具重置成另一个，或者重置回来"..
        "#将本房间内的塔罗牌变为反转版本"..
        "#!!! 部分道具的配对是固定的",
        BookOfVirtues = "摧毁所有本道具的灵火，或者生成3个"
    },
    [Collectibles.MiracleMallet.Item] = {
        Name = "万宝槌",
        Description = "!!! 一次性 !!!"..
        "#将本房间内的所有道具重置为{{Quality4}}品质4道具"..
        "#!!! 每重置一个道具，获得3颗{{BrokenHeart}}碎心",
        BookOfVirtues = "点金眼泪"
    },
    [Collectibles.ThunderDrum.Item] = {
        Name = "雷霆大鼓",
        Description = "斜向飞行的鼓跟班"..
        "#在鼓受到伤害后,砸出裂地波并生成18条激光"..
        "#每条激光造成15点伤害"..
        "#{{Player"..PlayerType.PLAYER_THEFORGOTTEN.."}} 可以被骨棒直接敲响"
    },
    [Collectibles.NimbleFabric.Item] = {
        Name = "闪避布",
        Description = "消耗1充能以暂时无敌"..
        "#期间无法移动或射击"..
        "#按住主动键以延长无敌时间",
        BookOfVirtues = "紫色灵火"
    },
    [Collectibles.MiracleMalletReplica.Item] = {
        Name = "万宝槌仿制品",
        Description = "锤击一个方向，造成80点伤害并生成裂地波",
        BookOfVirtues = "锤子灵火，熄灭后生成裂地波"
    },
    [Collectibles.RuneCape.Item] = {
        Name = "符文披风",
        Description = "↑  {{Shotspeed}}+0.16弹速"..
        "#掉落3个随机符文"
    },


    --TH15
    [Collectibles.LunaticGun.Item] = {
        Name = "月狂之枪",
        Description = "玩家持续按下射击键2秒后，射出锥形范围的一大团泪弹"..
        "#每颗泪弹穿墙且穿透，造成20%的玩家伤害，且没有击退"
    },
    [Collectibles.ViciousCurse.Item] = {
        Name = "恶毒的诅咒",
        Description = "获得{{Collectible" .. CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE ..
            "}}达摩克里斯之剑"..
        "#对角色造成一颗心的伤害"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE .. "}} 达摩克里斯之剑的更新速率翻倍"
    },
    [Collectibles.CarnivalHat.Item] = {
        Name = "狂欢帽",
        Description = "↑ 所有属性+0.01"..
        "#生成一张{{Card"..Card.CARD_JOKER.."}}鬼牌"..
        "#怪物死亡后生成即爆炸弹"..
        "#↑ 每受到一次爆炸伤害，{{Damage}}+0.1伤害"
    },
    [Collectibles.PureFury.Item] = {
        Name = "纯粹的愤怒",
        Description = "↑ {{Damage}}伤害x1.5"
    },
    [Collectibles.Hekate.Item] = {
        Name="权神星",
        Description = "三个行星环绕物"..
        "#异界环绕玩家,每秒造成105点接触伤害"..
        "#地球环绕异界,每秒造成75点接触伤害"..
        "#月球环绕地球,每秒造成45点接触伤害"
    },


    [Collectibles.DadsShares.Item] = {
        Name = "爸爸的股票",
        Description = "清理房间后，生成一个钱币"..
        "#受到伤害时，失去五个钱币"..
        "#!!! 自伤不触发该效果"
    },
    [Collectibles.MomsIOU.Item] = {
        Name = "妈妈的欠条",
        Description = "↓  {{Luck}}-3运气"..
        "#在商店中只卖1钱币"..
        "#充满角色的{{Coin}}钱币，直到上限"..
        "#每层支付本金20%的钱币，用于偿还20%利息的债务"..
        "#!!! 钱币不够时移除玩家的{{Collectible}}道具，然后是{{Heart}}血量"..
        "#还清债务后，欠条消失"
    },


    --TH16
    [Collectibles.YamanbasChopper.Item] = {
        Name = "山姥的柴刀",
        Description = "杀死敌人有几率恢复{{HalfHeart}}半颗红心"..
        "#受伤时有几率掉落{{Coin}}钱币"..
        "#概率基于{{Luck}}运气"..
        "#{{CurseBlind}} 该道具可以在致盲诅咒中显示"
    },
    [Collectibles.GolemOfIsaac.Item] = {
        Name = "以撒魔像",
        Description = "魔像跟班，会自动与敌人战斗"..
        "#会帮你按下按钮并打开{{SpikedChest}}{{TrapChest}}{{HauntedChest}}陷阱箱"..
        "#{{Damage}}伤害和{{Tears}}射速随着楼层的增加而增加"
    },
    [Collectibles.DancerServants.Item] = {
        Name = "狂舞童子",
        Description = "2个快速旋转的环绕物宝宝，向玩家射击方向的反方向射击"..
        "#{{ColorGreen}}绿色{{CR}}童子杀死的敌人有10%的几率掉落一颗{{SoulHeart}}魂心"..
        "#{{ColorPink}}品红{{CR}}童子杀死的敌人有20%的机率掉落一颗{{Heart}}红心"
    },
    [Collectibles.BackDoor.Item] = {
        Name = "背后之门",
        Description = "玩家背后的门跟班"..
        "#可以消除敌弹"..
        "#每秒造成52.5点接触伤害"
    },


    --TH17
    [Collectibles.FetusBlood.Item] = {
        Name = "胎儿之血",
        Description = "生成一个为你而战的血骷髅"..
        "#数量上限等同于当前层数",
        BookOfVirtues = "血肉灵火"
    },
    [Collectibles.CockcrowWings.Item] = {
        Name = "啼日之翼",
        Description = "飞行"..
        "#根据游戏时间循环昼夜："..
        "#{{Collectible589}} {{ColorPurple}}黎明 (0:00-0:30): {{CR}}"..
        "#{{Blank}} ↑{{Tears}}+0.5射速"..
        "#{{Collectible588}} {{ColorOrange}}白天 (0:30-2:00): {{CR}}"..
        "#{{Blank}} ↑{{Damage}}+1伤害"..
        "#{{Blank}} ↓{{Tears}}-0.5射速"..
        "#{{Collectible588}} {{ColorOrange}}黄昏 (2:00-2:30): {{CR}}"..
        "#{{Blank}} ↑{{Damage}}+0.5伤害"..
        "#{{Collectible589}} {{ColorPurple}}夜晚 (2:30-4:00): {{CR}}"..
        "#{{Blank}} ↑{{Tears}}+1射速"..
        "#{{Blank}} ↓{{Damage}}-0.5伤害"..
        "#{{Blank}} "..
        "#{{Collectible588}} 驱散{{CurseDarkness}}，显示{{BossRoom}}"..
        "#{{Collectible589}} 获得{{CurseDarkness}}，显示{{SecretRoom}}{{SuperSecretRoom}}{{UltraSecretRoom}}",
    },
    [Collectibles.KiketsuBlackmail.Item] = {
        Name = "鬼杰组的要挟",
        Description = "{{Fear}} 恐惧周围敌人"..
        "#{{Charm}} 魅惑更远范围内的敌人"
    },
    [Collectibles.CarvingTools.Item] = {
        Name = "雕刻工具",
        Description = "摧毁石头后生成埴轮士兵"..
        "#不同的石头会生成不同的埴轮"
    },
    [Collectibles.BrutalHorseshoe.Item] = {
        Name = "残暴马蹄铁",
        Description = "按住相反的移动键，或按下{{ButtonLStick}}手柄左摇杆以蓄力"..
        "#蓄力至少一秒后,向移动方向冲刺"..
        "#冲刺时无敌"..
        "#撞击障碍物后爆炸，并产生四条裂地波"..
        "#对撞击的敌人造成伤害并将其踢飞"
    },


    --TH17.5
    [Collectibles.Hunger.Item] = {
        Name = "饥饿",
        Description = "获得饥饿值系统"..
        "#角色在移动时失去饥饿值"..
        "#大于9时受到治疗"..
        "#大于8时属性提升"..
        "#小于3时属性下降，并吞下饰品"..
        "#为0时不断受到伤害"..
        "#怪物会掉落食物补给"
    },
    [Collectibles.SakeOfForgotten.Item] = {
        Name="遗忘清酒",
        Description = "击败Boss后生成清酒瓶，接触后重新开始这一层"..
        "#!!! 新的一层具有{{CurseMaze}}混乱、{{CurseLabyrinth}}迷宫和{{CurseLost}}迷途诅咒，并且整层玩家都会变为 {{Player"..PlayerType.PLAYER_THELOST.."}}游魂"..
        "#!!! 清酒瓶只能在单数层或者没有第二层的层出现"..
        "#!!! 新的一层不会生成酒瓶"
    },

    
    [Collectibles.GamblingD6.Item] = {
        Name = "赌博六面骰",
        Description = "选择赌大或者赌小，然后重置本房间的所有道具"..
        "#如果没有猜中被重置后的道具ID比原来大或者小，重置出的道具消失",
        BookOfVirtues = "猜错之后道具不再消失，改为消耗一个该道具的灵火"
    },
    [Collectibles.YamawarosCrate.Item] = {
        Name = "山童的木箱",
        Description = "提供储存道具和饰品的空间"..
        "#可以将道具和饰品拆解为基础掉落物"..
        "#可以被{{Collectible"..CollectibleType.COLLECTIBLE_CAR_BATTERY.."}}车载电池、{{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES.."}}美德之书和犹大的{{Collectible"..CollectibleType.COLLECTIBLE_BIRTHRIGHT.."}}长子权扩容",
        BookOfVirtues = "+2空间"..
        "#可以使用蓝色卷轴传送到初始房间",
        BookOfBelial = "+2空间"..
        "#可以使用红色卷轴重置该房间道具，每房间只能用一次"
    },
    [Collectibles.DelusionPipe.Item] = {
        Name = "迷幻烟斗",
        Description = "↑  {{Luck}}+10运气，在30秒内衰减完毕"..
        "#屏幕重影"..
        "#效果可以叠加",
        BookOfVirtues = "漩涡灵火，血量基于角色的运气提升程度",
        BookOfBelial = "在本层剩余时间内获得额外伤害加成，取决于本层的最高运气加成"
    },
    [Collectibles.SoulMagatama.Item] = {
        Name = "灵魂勾玉",
        Description = "发射勾玉，能够交换击中敌人的生命值和角色的{{Heart}}红心"..
        "#血量交换基于双方的血量百分比"..
        "#!!! 无法将Boss的血量降低到25%以下"..
        "#如果角色没有心之容器，将小怪变为错误店主，或将Boss的血量变为25%",
        BookOfVirtues = "吸血灵火"
    },
    [Collectibles.FoxInTube.Item] = {
        Name = "管中狐",
        Description = "某些情况下提供帮助"..
        "#!!! 如果你接受她的帮助，你会在之后付出代价"..
        "#她生成的玻璃瓶可以被眼泪打碎"
    },
    [Collectibles.DaitenguTelescope.Item] = {
        Name = "大天狗望远镜",
        Description = "进入新层后有几率在随机房间降下流星，并生成一个{{Planetarium}}星象房道具"..
        "#如果角色不进入{{TreasureRoom}}宝箱房，概率会提高，并在降下流星后回到1%"..
        "#{{Trinket" ..
            TrinketType.TRINKET_TELESCOPE_LENS .. "}}望远镜片，{{Collectible" ..
            CollectibleType.COLLECTIBLE_MAGIC_8_BALL .. "}}魔法8号球和{{Collectible" ..
            CollectibleType.COLLECTIBLE_CRYSTAL_BALL .. "}}水晶球会增加概率"
    },
    [Collectibles.ExchangeTicket.Item] = {
        Name = "交易所门票",
        Description = "将角色传送到交易所交易道具"..
        "#!!! 重新进入后所有内容都会被刷新",
        BookOfVirtues = "生成的灵火能被用作绿宝石"
    },
    [Collectibles.CurseOfCentipede.Item] = {
        Name = "百足的诅咒",
        Description = "变为{{Collectible" .. CollectibleType.COLLECTIBLE_MUTANT_SPIDER ..
            "}}突变蜘蛛，{{Collectible" .. CollectibleType.COLLECTIBLE_BELLY_BUTTON .. "}}肚脐，{{Collectible" ..
            CollectibleType.COLLECTIBLE_POLYDACTYLY .. "}}多指症，{{Collectible" ..
            CollectibleType.COLLECTIBLE_SCHOOLBAG .. "}}书包，{{Collectible" ..
            CollectibleType.COLLECTIBLE_LUCKY_FOOT ..
            "}}幸运脚"..
            "#{{Player"..PlayerType.PLAYER_ISAAC_B.."}} 腐化以撒拿不下的道具会掉在地上"
    },
    [Collectibles.RebelMechaCaller.Item] = {
        Name="反狱机甲呼叫机",
        Description = "从上方召唤一个机甲，砸伤所有周围的敌人"..
        "#接触以驾驶机甲，提供3次防御"..
        "#按下"..EID.ButtonToIconMap[ButtonAction.ACTION_ITEM].."以切换飞行模式"..
        "#按下"..EID.ButtonToIconMap[ButtonAction.ACTION_BOMB].."以发射炸弹"..
        "#按下"..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].."以离开机甲"..
        "#按下"..EID.ButtonToIconMap[ButtonAction.ACTION_PILLCARD].."以自爆",
        BookOfVirtues = "棕色心火，可以抵消一次机甲受伤"
    },
    [Collectibles.DSiphon.Item] = {
        Name="虹吸骰子",
        Description = "将本房间所有道具重置为{{ColorRed}}-1{{CR}}品质的道具"..
        "#每有一个被重置的道具{{ColorGreen}}+1{{CR}}计数"..
        "#计数达到4及以上时，数字反转",
        BookOfVirtues = "血量很高的黑色灵火，每次使用后灵火生命值都会减少"
    },

    [Collectibles.DreamSoul.Item] = {
        Name = "梦魂",
        Description = "只会生成在回溯时的地下室I层的{{TreasureRoom}}宝箱房内"..
        "#移除妈妈房间的门，然后在以撒的房间生成一个通往梦境世界的垫子"
    }
}

local EmptyBook= Collectibles.EmptyBook;
EIDInfo.KosuzuDescriptions = {
    Default = "无效果",
    Actives = {
        [EmptyBook.Sizes.SMALL] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "↑  {{Damage}}本房间内x1.25伤害",
            [EmptyBook.ActiveEffects.PRAYING] = "{{HalfHeart}} 恢复半颗红心",
            [EmptyBook.ActiveEffects.COLLECTION] = "{{Coin}} 有50%的几率生成一枚钱币",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "{{Collectible35}} 对所有怪物造成20点伤害",
            [EmptyBook.ActiveEffects.PROTECTION] = "{{Collectible58}} 获得3秒护盾",
            [EmptyBook.ActiveEffects.FAMILIARS] = "{{Collectible412}} 在本房间内生成1个来自恶魔受胎的跟班", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "{{Collectible285}} 重置所有怪物",
        },
        
        [EmptyBook.Sizes.MEDIUM] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "↑  {{Damage}}本房间内x1.5伤害",
            [EmptyBook.ActiveEffects.PRAYING] = "{{HalfSoulHeart}} 获得半颗魂心",
            [EmptyBook.ActiveEffects.COLLECTION] = "随机生成{{Coin}}钱币、{{Key}}钥匙、{{Bomb}}炸弹或{{Heart}}心",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "{{Collectible35}} 对所有怪物造成60点伤害",
            [EmptyBook.ActiveEffects.PROTECTION] = "{{Collectible58}} 获得10秒护盾",
            [EmptyBook.ActiveEffects.FAMILIARS] = "{{Collectible412}} 在本房间内生成3个来自恶魔受胎的跟班", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "{{Collectible437}} 重置本房间",
        },
        
        [EmptyBook.Sizes.LARGE] = {
            [EmptyBook.ActiveEffects.INCANTATION] = "↑  {{Damage}}本房间内x2伤害",
            [EmptyBook.ActiveEffects.PRAYING] = "{{EternalHeart}} 获得永恒之心",
            [EmptyBook.ActiveEffects.COLLECTION] = "生成{{Coin}}钱币、{{Key}}钥匙、{{Bomb}}炸弹和{{Heart}}心各一个",
            [EmptyBook.ActiveEffects.FORBIDDEN] = "{{Collectible35}} 对所有怪物造成180点伤害",
            [EmptyBook.ActiveEffects.PROTECTION] = "{{Collectible58}} 获得30秒护盾",
            [EmptyBook.ActiveEffects.FAMILIARS] = "{{Collectible412}} 在本房间内生成6个来自恶魔受胎的跟班", 
            [EmptyBook.ActiveEffects.EXPLORATION] = "{{Collectible105}} 重置本房间内的道具",
        },
    },
    Passives = {
        [EmptyBook.PassiveEffects.GOODWILLED] = "持有时，{{AngelChance}}天使房转换率+10%",
        [EmptyBook.PassiveEffects.WISE] = "持有时，驱除{{CurseUnknown}}未知、{{CurseBlind}}盲目、{{CurseLost}}迷失诅咒",
        [EmptyBook.PassiveEffects.PRECISE] = "{{Collectible"..CollectibleType.COLLECTIBLE_COMPASS.."}} 持有时，获得指南针效果",
        [EmptyBook.PassiveEffects.MEAN] = "{{Trinket35}} ↑持有时，{{Damage}}+2直接伤害",
        [EmptyBook.PassiveEffects.CLEAR] = "{{Trinket37}} ↑持有时，{{Speed}}+0.15移速",
        [EmptyBook.PassiveEffects.SELFLESS] = "{{Collectible156}} 持有时，受伤后为主动道具充能1格", 
        [EmptyBook.PassiveEffects.INNOVATIVE] = "{{Collectible584}} 使用后生成灵火",
    }
}

EIDInfo.Trinkets = {
    [Trinkets.FrozenFrog.Trinket] = {
        Name = "冻青蛙",
        Description = "{{Freezing}} 冻结角色接触到的非Boss敌人"
    },
    [Trinkets.AromaticFlower.Trinket] = {
        Name = "常樱之花",
        Description = "角色死亡后复活，并具有{{Heart}}心之容器一半的红心，该饰品消失",
        GoldenInfo = {findReplace = true},
        GoldenEffect = {"{{Heart}}心之容器一半的红心", "{{Heart}}满红心", "{{Heart}}满红心和2颗{{SoulHeart}}魂心"}
    },
    [Trinkets.GlassesOfKnowledge.Trinket] = {
        Name = "博学眼镜",
        Description = "角色每有一个道具："..
        "#↑  {{Speed}}+0.03移速"..
        "#↑  {{Damage}}+0.03伤害"..
        "#↑  {{Tears}}+0.02射速"..
        "#↑  {{Range}}+0.038射程",
        GoldenInfo = {t={0.03, 0.03, 0.02, 0.038}}
    },
    [Trinkets.HowToReadABook.Trinket] = {
        Name = "如何阅读一本书",
        Description = "提升书道具出现概率"
    },
    [Trinkets.CorrodedDoll.Trinket] = {
        Name = "腐蚀的人偶",
        Description = "角色每7帧流下绿色水迹，每帧造成20%的角色伤害，存在一秒",
        GoldenInfo = 20
    },
    [Trinkets.GhostAnchor.Trinket] = {
        Name="幽灵船锚",
        Description = "↑  {{Speed}}+0.3移速"..
        "#玩家的移动没有惯性,并且严格按照输入方向移动"..
        "#玩家不再受到地面水流的影响",
        GoldenInfo = nil
    },
    [Trinkets.MermanShell.Trinket] = {
        Name = "鱼人贝壳",
        Description = "在被水淹没的房间获得："..
        "#↑  {{Damage}}+2攻击力"..
        "#↑  {{Tears}}+1射速"..
        "#↑  {{Speed}}+0.15移速"..
        "#进入下一层后，淹没20%的房间",
        GoldenInfo = {t={20}}
    },
    [Trinkets.Dangos.Trinket] = {
        Name = "团子",
        Description = "持有时没有效果"..
        "#吞下时获得这些属性："..
        "#↑  {{Tears}}+0.5射速"..
        "#↑  {{Damage}}+1伤害"..
        "#↑  {{Range}}+1.5射程"..
        "#↑  {{Shotspeed}}+0.2弹速"..
        "#↑  {{Luck}}+1运气",
        GoldenInfo = {fullReplace = true},
        GoldenEffect = {
            "持有时{{ColorGold}}获得这些属性{{CR}}："..
            "#↑  {{Tears}}+0.5射速"..
            "#↑  {{Damage}}+1伤害"..
            "#↑  {{Range}}+1.5射程"..
            "#↑  {{Shotspeed}}+0.2弹速"..
            "#↑  {{Luck}}+1运气"..
            "#吞下时再次获得这些属性",

            "持有时{{ColorGold}}获得这些属性{{CR}}："..
            "#↑  {{Tears}}+0.5射速"..
            "#↑  {{Damage}}+1伤害"..
            "#↑  {{Range}}+1.5射程"..
            "#↑  {{Shotspeed}}+0.2弹速"..
            "#↑  {{Luck}}+1运气"..
            "#吞下时再次获得这些属性",

            "持有时{{ColorGold}}获得这些属性两次{{CR}}："..
            "#↑  {{Tears}}+0.5射速"..
            "#↑  {{Damage}}+1伤害"..
            "#↑  {{Range}}+1.5射程"..
            "#↑  {{Shotspeed}}+0.2弹速"..
            "#↑  {{Luck}}+1运气"..
            "#吞下时再次获得这些属性",
        }
    },
    [Trinkets.ButterflyWings.Trinket] = {
        Name = "蝴蝶翅膀",
        Description = "角色清理房间后,获得飞行"..
        "#再次清理房间后,失去飞行",
        GoldenInfo = {fullReplace = true},
        GoldenEffect = {
            "{{ColorGold}}飞行", 
            "{{ColorGold}}飞行", 
            "{{ColorGold}}飞行"
        }
    },
    [Trinkets.LionStatue.Trinket] = {
        Name = "狮子雕像",
        Description = "在有天使雕像的房间额外生成1座天使雕像",
        GoldenInfo = 1
    },
    [Trinkets.BundledStatue.Trinket] = {
        Name = "襁褓石像",
        Description = "↓  {{Speed}}-0.15移速"..
        "#所有敌弹更快坠落至地面",
        GoldenInfo = {findReplace = true},
        GoldenEffect = {
            "更快",
            "更快",
            "更快"
        }
    },
    [Trinkets.ShieldOfLoyalty.Trinket] = {
        Name = "忠诚之盾",
        Description = "所有跟班都能抵挡敌弹"..
        "#蓝苍蝇和蓝蜘蛛在抵挡敌弹后死亡"
    },
    [Trinkets.SwordOfLoyalty.Trinket] = {
        Name = "忠诚之剑",
        Description = "所有跟班每秒额外造成15点接触伤害"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} 在有好朋友一辈子！时造成30点伤害",
        GoldenInfo = {fullReplace = true},
        GoldenEffect = {
            "所有跟班每秒额外造成{{ColorGold}}30{{ColorText}}点接触伤害"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} 在有好朋友一辈子！时造成{{ColorGold}}60{{ColorText}}点伤害",
            "所有跟班每秒额外造成{{ColorGold}}30{{ColorText}}点接触伤害"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} 在有好朋友一辈子！时造成{{ColorGold}}60{{ColorText}}点伤害",
            "所有跟班每秒额外造成{{ColorGold}}45{{ColorText}}点接触伤害"..
        "#{{Collectible"..CollectibleType.COLLECTIBLE_BFFS.."}} 在有好朋友一辈子！时造成{{ColorGold}}90{{ColorText}}点伤害",
        },
    },
    [Trinkets.FortuneCatPaw.Trinket] = {
        Name = "招财猫爪",
        Description = "敌人死亡后有25%的几率掉落1颗临时{{Coin}}钱币"..
        "#Boss总会掉落3颗临时{{Coin}}钱币",
        GoldenInfo = {t={1, 3}}
    }
};

EIDInfo.RuneSword = {
    [Card.RUNE_ANSUZ] = "显示所有曼哈顿距离{DISTANCE}格内的房间",
    [Card.RUNE_DAGAZ] = "没有诅咒，镶嵌时获得两颗魂心",
    [Card.RUNE_HAGALAZ] = "眼泪有{CHANCE}%的几率变为石头",
    [Card.RUNE_PERTHRO] = "玩家的炸弹炸到道具时，会重置该道具#有{CHANCE}%的几率会直接消失",
    [Card.RUNE_EHWAZ] = "击败本层BOSS后，生成一个通往地下室的活板门",
    [Card.RUNE_BERKANO] = "清理一个房间后，生成{COUNT}个蓝苍蝇和{COUNT}个蓝蜘蛛",
    [Card.RUNE_ALGIZ] = "受到伤害后，有{CHANCE}%的几率触发{{Collectible58}}影之书的效果",
    [Card.RUNE_JERA] = "进入新的房间后，有{CHANCE}%的几率将掉落物翻倍#超出100%的几率会转化为新的掉落物",
    [Card.RUNE_BLACK] = "全属性上升",
    [Card.RUNE_BLANK] = "改为镶嵌一个随机的基础符文",
    [Card.RUNE_SHARD] = "改为镶嵌一个随机的基础符文",
    [Card.CARD_SOUL_ISAAC] = "进入新的房间后，有{CHANCE}%的几率触发该符文效果#超出100%的几率会转化为新的次数",
    [Card.CARD_SOUL_MAGDALENE] = "进入一个有怪物的房间后，触发该符文效果",
    [Card.CARD_SOUL_CAIN] = "清理一个房间后，有{CHANCE}%的几率触发该符文效果#如果未触发，该概率会累积",
    [Card.CARD_SOUL_JUDAS] = "每房间{COUNT}次，被子弹或敌人击中前，触发该符文效果",
    [Card.CARD_SOUL_BLUEBABY] = "按住射击键3秒后，生成一个大便炸弹",
    [Card.CARD_SOUL_EVE] = "受到伤害后，在本房间内生成{COUNT}只死鸟",
    [Card.CARD_SOUL_SAMSON] = "累计造成或受到{DAMAGE}点伤害后，触发该符文效果",
    [Card.CARD_SOUL_AZAZEL] = "清理4个房间后，进入存在怪物的房间会触发该符文效果",
    [Card.CARD_SOUL_LAZARUS] = "死亡时，如果有镶嵌该符文，消耗一个该符文并触发该符文效果",
    [Card.CARD_SOUL_EDEN] = "镶嵌时，生成一个随机道具",
    [Card.CARD_SOUL_LOST] = "镶嵌时，使用{{Card"..Card.CARD_HOLY.."}}神圣卡#进入一个新房间后，有{CHANCE}%的几率使用一次{{Card"..Card.CARD_HOLY.."}}神圣卡",
    [Card.CARD_SOUL_LILITH] = "击败本层BOSS后，触发一次该符文效果",
    [Card.CARD_SOUL_KEEPER] = "怪物死亡时有{CHANCE}%的几率掉落随机临时钱币#超出100%的几率会转化为新的钱币",
    [Card.CARD_SOUL_APOLLYON] = "清理房间后生成{COUNT}个随机蝗虫",
    [Card.CARD_SOUL_FORGOTTEN] = "受到伤害后，有{CHANCE}%的几率掉落一颗骨心",
    [Card.CARD_SOUL_BETHANY] = "清理房间后，生成{COUNT}个灵火",
    [Card.CARD_SOUL_JACOB] = "镶嵌时，生成{{Collectible619}}长子名分",
    [Cards.SoulOfEika.ID] = "怪物死亡时有{CHANCE}%的几率生成一个友方血骷髅",
    [Cards.SoulOfSatori.ID] = "眼泪有{CHANCE}%的几率变为精神控制泪弹",
    [Cards.SoulOfSeija.ID] = "获得{{Player"..Players.Seija.Type.."}}正邪的被动效果"..
    "#镶嵌{{Card"..Cards.SoulOfSeija.ReversedID.."}}另一半正邪的魂石不会削弱高品质道具",
    [Cards.SoulOfSeija.ReversedID] = "获得{{Player"..Players.Seija.Type.."}}正邪的被动效果"..
    "#镶嵌{{Card"..Cards.SoulOfSeija.ID.."}}另一半正邪的魂石不会削弱高品质道具"
}

EIDInfo.Cards = {
    [Isaac.GetCardIdByName ("VoidHandThree")] = {
        Name = "虚空之手",
        Type = "CARD",
        Description = "将本房间的所有口袋物品变为底座道具",
    },
    [Isaac.GetCardIdByName ("VoidHandTwo")] = {
        Name = "虚空之手",
        Type = "CARD",
        Description = "将本房间的所有口袋物品变为底座道具",
    },
    [Isaac.GetCardIdByName ("VoidHandOne")] = {
        Name = "虚空之手",
        Type = "CARD",
        Description = "将本房间的所有口袋物品变为底座道具",
    },
    [Cards.SoulOfEika.ID] = {
        Name = "璎花的魂石",
        Type = "SOUL",
        Description = "生成3个友方血骷髅"..
        "#将本房间内的所有心变形为对应的友方骷髅",
    },
    [Cards.SoulOfSatori.ID] = {
        Name = "觉的魂石",
        Type = "SOUL",
        Description = "{{Charm}} 精神控制本房间的所有小怪,魅惑所有Boss",
    },
    [Cards.SoulOfSeija.ID] = {
        Name = "正邪的魂石",
        Type = "SOUL",
        Description = "使用{{Collectible"..Collectibles.DFlip.Item.."}}镜像骰子"..
        "#获得另一半{{Card"..THI.Cards.SoulOfSeija.ReversedID.."}}正邪的魂石",
    },
    [Cards.SoulOfSeija.ReversedID] = {
        Name = "正邪的魂石",
        Type = "SOUL",
        Description = "使用{{Collectible"..Collectibles.DFlip.Item.."}}镜像骰子",
    },
    [Cards.ASmallStone.ID] = {
        Name = "小石块",
        Type = "CARD",
        Description = "向射击方向发射一颗石头眼泪"..
        "#仅有1点伤害，每次使用后都会永久增加1点"..
        "#生成一张{{Card"..Cards.ASmallStone.ID.."}}小石块",
    },
    [Cards.SpiritMirror.ID] = {
        Name = "精神之镜",
        Type = "CARD",
        Description = "生成本房间内每个敌人的一个友方复制",
    },
    [Cards.SituationTwist.ID] = {
        Name = "形势反转",
        Type = "CARD",
        Description = "重置本房间内的所有道具"..
        "#被重置的道具会替换之后的道具",
    },
}
EIDInfo.Pills = {
    [THI.Pills.PillOfUltramarineOrb.ID] = {
        Name = "绀珠药丸",
        Type = "PILL",
        Description = "当前房间受伤后使用{{Collectible"..CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS.."}}发光沙漏，该药丸消失"..
        "#大药丸不会消耗",
    }
}


EIDInfo.Birthrights = {
    [Players.Eika.Type] = {
        Description = "可以堆叠20个石头",
        PlayerName = "璎花"
    },
    [Players.EikaB.Type] = {
        Description = "血骷髅在死亡后爆炸"..
        "#不会伤到玩家",
        PlayerName = "堕化璎花"
    },
    [Players.Satori.Type] = {
        Description = "{{Collectible"..Collectibles.PsycheEye.Item.."}}精神眼提供的属性提升翻倍",
        PlayerName = "觉"
    },
    [Players.SatoriB.Type] = {
        Description = "↑  {{Speed}}移速+最大移速提升"..
        "#{{Speed}} 移速大于等于1时碾压会造成爆炸",
        PlayerName = "堕化觉"
    },
    [Players.Seija.Type] = {
        Description = "不再削弱道具",
        PlayerName = "正邪"
    },
    [Players.SeijaB.Type] = {
        Description = "被动效果改为只阻止{{Quality0}}级道具生成",
        PlayerName = "堕化正邪"
    },
}

EIDInfo.LunaticDescs = {
    Collectibles = {
        [Collectibles.DarkRibbon.Item] = "增加的伤害倍率变为20%",
        [Collectibles.DYSSpring.Item] = "妖精只会治疗一颗{{Heart}}红心和一颗{{SoulHeart}}魂心",
        [Collectibles.MaidSuit.Item] = "只能时间停止2秒钟，{{Card22}}XXI-世界改为在击败Boss后生成。",
        [Collectibles.VampireTooth.Item] = "心掉落率减少为2.5%",
        [Collectibles.Roukanken.Item] = "杀死敌人不回复充能",
        [Collectibles.FanOfTheDead.Item] = "生命上限为20",
        [Collectibles.OneOfNineTails.Item] = "在达到上限9之后不再生成道具",
        [Collectibles.Starseeker.Item] = "选项只有两个",
        [Collectibles.BookOfYears.Item] = "有30%的几率不生成道具",
        [Collectibles.TenguCamera.Item] = "石化时间缩短到4秒",
        --[Collectibles.RuneSword.Item] = "马骑符文地下室生成概率降低为每个符文+50%",
        [Collectibles.Pagota.Item] = "对怪物不再有点金效果",
        [Collectibles.ZombieInfestation.Item] = "怪物只有50%的几率生成友方复制",
        [Collectibles.D2147483647.Item] = "需要2充能转换成为主动道具，并且排除了{{Collectible" ..
            CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE .. "}}死亡证明",
        [Collectibles.TheInfamies.Item] = "不再魅惑Boss",
        --[Collectibles.Hunger.Item] = "怪物不再掉落食物",
    },
    Trinkets = {
        [Trinkets.FortuneCatPaw.Trinket] = "boss掉落钱币的概率变为60%",
    }
}

EIDInfo.SeijaBuffs = {
    Collectibles = {
        [CollectibleType.COLLECTIBLE_MY_REFLECTION] = "↓ x0.75{{Range}}射程"..
        "#发射手里剑眼泪，穿透并穿墙，并且每帧对接触到的敌人造成伤害",
        [CollectibleType.COLLECTIBLE_SKATOLE] = "将所有苍蝇变为友方"..
        "#敌人死亡后生成1只蓝苍蝇",
        [CollectibleType.COLLECTIBLE_BOOM] = "额外+89炸弹",
        [CollectibleType.COLLECTIBLE_POOP] = "生成金大便",
        [CollectibleType.COLLECTIBLE_KAMIKAZE] = "触发一次本房间内的{{Collectible"..CollectibleType.COLLECTIBLE_MAMA_MEGA.."}}妈妈炸弹的效果",
        [CollectibleType.COLLECTIBLE_MOMS_PAD] = "对所有敌人造成40点伤害，击杀敌人后掉落一颗红心",
        [CollectibleType.COLLECTIBLE_TELEPORT] = "依次传送至未访问的{{TreasureRoom}}宝箱房、{{UltraSecretRoom}}究极隐藏房、{{DevilRoom}}恶魔/{{AngelRoom}}天使房、错误房",
        [CollectibleType.COLLECTIBLE_BEAN] = "所有敌人放屁并中毒",
        [CollectibleType.COLLECTIBLE_DEAD_BIRD] = "击杀敌人后在本房间内生成一只死鸟",
        [CollectibleType.COLLECTIBLE_RAZOR_BLADE] = "使用后{{Damage}}伤害翻倍并触发{{Card"..Card.CARD_SOUL_MAGDALENE.."}}抹大拉的魂石的效果",
        [CollectibleType.COLLECTIBLE_PAGEANT_BOY] = "拾取时额外生成镍币，铸币，金硬币和幸运币"..
        "#硬币有几率被替换为镍币、铸币、金硬币或幸运币",
        [CollectibleType.COLLECTIBLE_BUM_FRIEND] = "50%的几率给予乞丐道具池的道具",
        [CollectibleType.COLLECTIBLE_INFESTATION] = "敌人受击后50%几率{{Poison}}中毒并生成1只蓝苍蝇",
        [CollectibleType.COLLECTIBLE_PORTABLE_SLOT] = "失败后50%几率获得1{{Coin}}硬币",
        [CollectibleType.COLLECTIBLE_BLACK_BEAN] = "受伤后周围敌人放屁并{{Poison}}中毒"..
        "#敌人死后也触发该效果",
        [CollectibleType.COLLECTIBLE_BLOOD_RIGHTS] = "额外造成40点伤害，所有怪物永久流血"..
        "#流血的怪物死亡后掉落临时半红心",
        [CollectibleType.COLLECTIBLE_ABEL] = "持续对周围的敌人造成每秒128点伤害和燃烧效果"..
        "#使用激光链接角色和亚伯，对激光内的敌人造成伤害",
        [CollectibleType.COLLECTIBLE_TINY_PLANET] = "子弹击中敌人后在随机位置砸下陨石爆炸，伤害为10倍玩家伤害"..
        "#不会炸伤自己",
        [CollectibleType.COLLECTIBLE_MISSING_PAGE_2] = "↑ +1{{Damage}}伤害"..
        "#受伤后触发{{Collectible"..CollectibleType.COLLECTIBLE_NECRONOMICON.."}}死灵之书的效果",
        [CollectibleType.COLLECTIBLE_BEST_BUD] = "一直触发效果"..
        "#白苍蝇会击退靠近的敌人，并造成伤害和眩晕",
        [CollectibleType.COLLECTIBLE_ISAACS_HEART] = "心脏对怪物具有斥力",
        [CollectibleType.COLLECTIBLE_D10] = "所有非首领敌人有80%的几率变为苍蝇",
        [CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS] = "连续使用四次",
        [CollectibleType.COLLECTIBLE_KEY_BUM] = "额外给予一把{{Collectible"..CollectibleType.COLLECTIBLE_LATCH_KEY.."}}弹簧锁钥匙",
        [CollectibleType.COLLECTIBLE_PUNCHING_BAG] = "将附近的敌人拉至身旁反复拳击",
        [CollectibleType.COLLECTIBLE_OBSESSED_FAN] = "存在敌人时每秒生成2只蓝苍蝇",
        [CollectibleType.COLLECTIBLE_THE_JAR] = "清理房间后必定掉落随机心",
        [CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR] = "眼泪会持续电击周围敌人",
        [CollectibleType.COLLECTIBLE_CURSED_EYE] = "↑ 翻倍{{Tears}}射速",
        [CollectibleType.COLLECTIBLE_CAINS_OTHER_EYE] = "朝最近的敌人射击硫磺火"..
        "#进入下一层后，揭示本层形状",
        [CollectibleType.COLLECTIBLE_ISAACS_TEARS] = "只需一发眼泪即可满充能",
        [CollectibleType.COLLECTIBLE_BREATH_OF_LIFE] = "充能不满时一直无敌",
        [CollectibleType.COLLECTIBLE_BETRAYAL] = "进入房间后魅惑50%的怪物"..
        "#受伤后，使用{{Card"..THI.Cards.SoulOfSatori.ID.."}}觉的魂石",
        [CollectibleType.COLLECTIBLE_MY_SHADOW] = "敌人脚下不停生成黑蛆"..
        "#黑蛆死亡后爆炸，不伤害角色",
        [CollectibleType.COLLECTIBLE_LINGER_BEAN] = "毒云出现频率更快，并且会自动飞向敌人",
        [CollectibleType.COLLECTIBLE_SHADE] = "进入房间后为每个敌人生成一个正邪的影子"..
        "#对所有接触到的敌人造成每秒90点的接触伤害"..
        "#敌人死亡后影子消失",
        [CollectibleType.COLLECTIBLE_HUSHY] = "停滞时发射三条{{Collectible"..CollectibleType.COLLECTIBLE_CONTINUUM.."}}连续统泪弹链",
        [CollectibleType.COLLECTIBLE_PLAN_C] = "获得{{Collectible"..CollectibleType.COLLECTIBLE_1UP.."}}1UP!",
        [CollectibleType.COLLECTIBLE_DATAMINER] = "使用后："..
        "#↑ +0.1移速 ↑ +0.25射速"..
        "#↑ +0.5伤害 ↑ +0.75射程"..
        "#↑ +0.5幸运",
        [CollectibleType.COLLECTIBLE_CLICKER] = "生成一个品质{{Quality4}}的道具",
        [CollectibleType.COLLECTIBLE_SCOOPER] = "额外使用5次"..
        "#↑ 每次使用后+5伤害，每秒减少1.07点",
    
    
    
    
        [CollectibleType.COLLECTIBLE_BROWN_NUGGET] = "充能只需半秒",


        [CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER] = "不会受到爆炸伤害",
        [CollectibleType.COLLECTIBLE_MISSING_NO] = "进入下一层后获得满魂心"..
        "#不再遇到{{Collectible"..CollectibleType.COLLECTIBLE_TMTRAINER.."}}错误技",
        [CollectibleType.COLLECTIBLE_OUIJA_BOARD] = "↑ +1{{Tears}}射速"..
        "#穿透泪弹",
        [CollectibleType.COLLECTIBLE_GLAUCOMA] = "额外概率发射眩晕眼泪"..
        "#眩晕眼泪击中敌人后会闪光，眩晕周围所有敌人并对其造成200%角色伤害，且消除附近的敌弹"..
        "#9幸运时50%",
        [CollectibleType.COLLECTIBLE_TAURUS] = "{{Speed}}移速变为1.95",
        [CollectibleType.COLLECTIBLE_THE_WIZ] = "跟踪+穿透眼泪",
        [CollectibleType.COLLECTIBLE_ATHAME] = "黑色激光击杀敌人20%几率掉落黑心",
        [Collectibles.GreenEyedEnvy.Item] = "分裂出的怪物被魅惑5分钟",
        [Collectibles.ViciousCurse.Item] = "不再伤害角色，+1魂心"..
        "#复原{{Collectible"..CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE.."}}达摩克里斯之剑的更新速度"..
        "#即将被{{Collectible"..CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE.."}}达摩克里斯之剑杀死时保护玩家"
    },
    Modded = "↑ 全属性上升"
}
EIDInfo.SeijaNerfs = {
    Collectibles = {
        [CollectibleType.COLLECTIBLE_CRICKETS_HEAD] = "↓ -33%{{Tears}}射速",
        [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = "↓ -0.8{{Speed}}移速",
        [CollectibleType.COLLECTIBLE_DR_FETUS] = "爆炸时间变为三倍",
        [CollectibleType.COLLECTIBLE_D6] = "有30%的几率道具消失",
        [CollectibleType.COLLECTIBLE_WAFER] = "受伤时有50%的几率额外受伤一次",
        [CollectibleType.COLLECTIBLE_MOMS_KNIFE] = "↓ -25%{{Tears}}射速 ↓-25%{{Damage}}伤害 跟踪",
        [CollectibleType.COLLECTIBLE_BRIMSTONE] = "激光受{{Range}}射程影响（如同{{Player"..PlayerType.PLAYER_AZAZEL.."}}阿萨泻勒）",
        [CollectibleType.COLLECTIBLE_IPECAC] = "回旋眼泪",
        [CollectibleType.COLLECTIBLE_EPIC_FETUS] = "导弹下落时间翻倍",
        [CollectibleType.COLLECTIBLE_POLYPHEMUS] = "↓ -25%{{Tears}}射速",
        [CollectibleType.COLLECTIBLE_SACRED_HEART] = "↓ -50%{{Tears}}射速 ↓-0.5{{Speed}}移速 ↓-2.5{{Range}}射程 ↓-3{{Luck}}幸运"..
        "#↑ +1{{Shotspeed}}弹速",
        [CollectibleType.COLLECTIBLE_PYROMANIAC] = "敌人受到爆炸伤害时改为恢复血量",
        [CollectibleType.COLLECTIBLE_STOP_WATCH] = "↓ -0.6{{Speed}}移速",
        [CollectibleType.COLLECTIBLE_INFESTATION_2] = "怪物死亡时生成敌对蜘蛛",
        [CollectibleType.COLLECTIBLE_PROPTOSIS] = "↓ -1{{Shotspeed}}弹速",
        [CollectibleType.COLLECTIBLE_SATANIC_BIBLE] = "使用后+1{{BrokenHeart}}碎心",
        [CollectibleType.COLLECTIBLE_HOLY_MANTLE] = "永久变为{{Player"..PlayerType.PLAYER_THELOST.."}}游魂",
        [CollectibleType.COLLECTIBLE_GODHEAD] = "↑ +2.3{{Shotspeed}}弹速",
        [CollectibleType.COLLECTIBLE_INCUBUS] = "↓ -25%{{Damage}}伤害",
        [CollectibleType.COLLECTIBLE_TECH_X] = "↑ +2{{Shotspeed}}弹速",
        [CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID] = "被激光击杀的怪物爆炸",
        [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = "{{Heart}}红心逐渐流失",
        [CollectibleType.COLLECTIBLE_MEGA_BLAST] = "激光受{{Range}}射程影响",
        [CollectibleType.COLLECTIBLE_VOID] = "↓ 吸收一个道具后全属性略微下降",
        [CollectibleType.COLLECTIBLE_D_INFINITY] = "清理房间后有33%的几率减少一格充能",
        [CollectibleType.COLLECTIBLE_PSY_FLY] = "速度大幅度减慢",
        [CollectibleType.COLLECTIBLE_MEGA_MUSH] = "没有接触伤害",
        [CollectibleType.COLLECTIBLE_REVELATION] = "激光受{{Range}}射程影响",
        [CollectibleType.COLLECTIBLE_BINGE_EATER] = "↓ 每有一个食物道具额外-0.12{{Speed}}移速",
        [CollectibleType.COLLECTIBLE_C_SECTION] = "有5%的几率发射一只敌对的死胎",
        [CollectibleType.COLLECTIBLE_GLITCHED_CROWN] = "道具有80%的几率变为{{Collectible"..CollectibleType.COLLECTIBLE_GLITCHED_CROWN.."}}错误王冠",
        [CollectibleType.COLLECTIBLE_TWISTED_PAIR] = "↓ -40%{{Damage}}伤害",
        [CollectibleType.COLLECTIBLE_ABYSS] = "↓ 吸收一个道具后-10%{{Damage}}伤害",
        [CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING] = "有75%的概率合成失败",
        [CollectibleType.COLLECTIBLE_FLIP] = "有50%的概率道具消失",
        [CollectibleType.COLLECTIBLE_SPINDOWN_DICE] = "随机将道具ID再减少0-2",
        [CollectibleType.COLLECTIBLE_ROCK_BOTTOM] = "↑ 全属性翻倍，并在之后不再变化",
        [CollectibleType.COLLECTIBLE_HOLY_LIGHT] = "圣光只有33%角色伤害",
        [Collectibles.DarkRibbon.Item] = "圈内的敌人死亡后生成敌对黑蛆",
        [Collectibles.VampireTooth.Item] = "所有心逐渐流失",
        [Collectibles.FanOfTheDead.Item] = "在上一个房间复活",
        [Collectibles.SaucerRemote.Item] = "飞碟会攻击角色",
        [Collectibles.D2147483647.Item] = "只能选择品质{{Quality0}}和品质{{Quality1}}的主动道具",
        [Collectibles.WildFury.Item] = "↓ 击杀敌人改为属性下降",
        [Collectibles.PureFury.Item] = "↑ 改为{{Damage}}伤害x1.01",
        [Collectibles.CurseOfCentipede.Item] = "还会给予{{Collectible"..CollectibleType.COLLECTIBLE_SACRED_HEART.."}}圣心和{{Collectible"..CollectibleType.COLLECTIBLE_POLYPHEMUS.."}}巨人独眼",
        [CollectibleType.COLLECTIBLE_MISSING_NO] = "不再遇到品质{{Quality4}}道具"
    },
    Modded = "↓ 全属性下降"
}
return EIDInfo;
