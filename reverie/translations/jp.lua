local Translation = {}

Translation.Fonts = {
    ["DOREMY_DIALOG"] = THI.Fonts.Lanapixel,
    ["DOREMY_SPELL_CARD"] = THI.Fonts.Lanapixel,
    ["D2147483647_PAGE"] = THI.Fonts.Lanapixel,
    ["REPAY"] = THI.Fonts.Lanapixel,
    ["MUSICS"] = THI.Fonts.MPlus12b,
    ["MAGATAMA"] = THI.Fonts.Lanapixel,
    ["CAMERA_SCORE"] = THI.Fonts.Lanapixel,
    ["UFO_TIMER"] = THI.Fonts.Terminus8,
    ["TRADER_COUNT"] = THI.Fonts.Terminus8,
    ["CRATE"] = THI.Fonts.Lanapixel,
}

Translation.Default = {
--もしかしたら英語の注釈よりも日本語での注釈を翻訳サイトにかけた方が意味わかりやすいかもしれないです。
--english Annotation is bad?sorry... please japanise Annotation running translation site.
    ["#GRIMOIRE_SUN_NAME"] = "日",
    ["#GRIMOIRE_MOON_NAME"] = "月",
    ["#GRIMOIRE_FIRE_NAME"] = "火",
    ["#GRIMOIRE_WATER_NAME"] = "水",
    ["#GRIMOIRE_WOOD_NAME"] = "木",
    ["#GRIMOIRE_METAL_NAME"] = "金",
    ["#GRIMOIRE_EARTH_NAME"] = "土",
    ["#GRIMOIRE_SUN_DESCRIPTION"] = "ホーミング",
    ["#GRIMOIRE_MOON_DESCRIPTION"] = "誘惑",
    ["#GRIMOIRE_FIRE_DESCRIPTION"] = "やけど",
    ["#GRIMOIRE_WATER_DESCRIPTION"] = "スロー",
    ["#GRIMOIRE_WOOD_DESCRIPTION"] = "毒",
    ["#GRIMOIRE_METAL_DESCRIPTION"] = "磁力",
    ["#GRIMOIRE_EARTH_DESCRIPTION"] = "岩石",



    ["#TRANSFORMATION_MUSICIAN"] = "ミュージシャン!",

    ["#KOSUZU_BOOK_TEMPLATE_NAME"] = "{CLASS} の {SIZE}",
    ["#KOSUZU_BOOK_TEMPLATE_DESCRIPTION"] = "{ADJECTIVE}.",
    ["#KOSUZU_BOOK_SIZE_DEFAULT"] = "本",
    ["#KOSUZU_BOOK_CLASS_DEFAULT"] = "白紙", 
    ["#KOSUZU_BOOK_ADJECTIVE_DEFAULT"] = "...まっしろ",
    ["#KOSUZU_BOOK_SIZE_SMALL"] = "マニュアル",
    ["#KOSUZU_BOOK_SIZE_MEDIUM"] = "ガイド",
    ["#KOSUZU_BOOK_SIZE_LARGE"] = "歴史",
    ["#KOSUZU_BOOK_CLASS_STAT"] = "魔術", 
    ["#KOSUZU_BOOK_CLASS_HEART"] = "祈り", 
    ["#KOSUZU_BOOK_CLASS_PICKUP"] = "コレクション", 
    ["#KOSUZU_BOOK_CLASS_DAMAGE"] = "禁忌", 
    ["#KOSUZU_BOOK_CLASS_SHIELD"] = "守り", 
    ["#KOSUZU_BOOK_CLASS_SUMMON"] = "使い魔", 
    ["#KOSUZU_BOOK_CLASS_DICE"] = "探検", 
    ["#KOSUZU_BOOK_ADJECTIVE_ANGEL"] = "恵まれてる！",
    ["#KOSUZU_BOOK_ADJECTIVE_NO_CURSE"] = "かしこい！",
    ["#KOSUZU_BOOK_ADJECTIVE_COMPASS"] = "正確！",
    ["#KOSUZU_BOOK_ADJECTIVE_DAMAGE"] = "平均的！",
    ["#KOSUZU_BOOK_ADJECTIVE_SPEED"] = "クリア！",
    ["#KOSUZU_BOOK_ADJECTIVE_HABIT"] = "無私！",
    ["#KOSUZU_BOOK_ADJECTIVE_WISP"] = "美徳！",
    
    ["#RUNE_SWORD_HAGALAZ_NAME"] = "ハガラズ", 
    ["#RUNE_SWORD_JERA_NAME"] = "ジェラ", 
    ["#RUNE_SWORD_EHWAZ_NAME"] = "エワズ", 
    ["#RUNE_SWORD_DAGAZ_NAME"] = "ダガズ", 
    ["#RUNE_SWORD_ANSUZ_NAME"] = "アンスズ", 
    ["#RUNE_SWORD_PERTHRO_NAME"] = "パスロ", 
    ["#RUNE_SWORD_BERKANO_NAME"] = "ベルカノ", 
    ["#RUNE_SWORD_ALGIZ_NAME"] = "アルギズ", 
    ["#RUNE_SWORD_BLANK_RUNE_NAME"] = "ブランク", 
    ["#RUNE_SWORD_BLACK_RUNE_NAME"] = "ブラック", 
    ["#RUNE_SWORD_RUNE_SHARD_NAME"] = "欠片", 
    ["#RUNE_SWORD_ISAAC_NAME"] = "アイザック", 
    --「ソウル」を省略しています　omit the 「Soul」
    ["#RUNE_SWORD_MAGDALENE_NAME"] = "マグダーレン", 
    ["#RUNE_SWORD_CAIN_NAME"] = "カイン", 
    ["#RUNE_SWORD_JUDAS_NAME"] = "ユダ", 
    ["#RUNE_SWORD_BLUE_BABY_NAME"] = "???", 
    ["#RUNE_SWORD_EVE_NAME"] = "イブ", 
    ["#RUNE_SWORD_SAMSON_NAME"] = "サムソン", 
    ["#RUNE_SWORD_AZAZEL_NAME"] = "アザゼル", 
    ["#RUNE_SWORD_LAZARUS_NAME"] = "ラザラス", 
    ["#RUNE_SWORD_EDEN_NAME"] = "エデン", 
    ["#RUNE_SWORD_LOST_NAME"] = "ロスト", 
    ["#RUNE_SWORD_LILITH_NAME"] = "リリス", 
    ["#RUNE_SWORD_KEEPER_NAME"] = "キーパー", 
    ["#RUNE_SWORD_APOLLYON_NAME"] = "アポリオン", 
    ["#RUNE_SWORD_FORGOTTEN_NAME"] = "フォーガットン", 
    ["#RUNE_SWORD_BETHANY_NAME"] = "ベタニア", 
    ["#RUNE_SWORD_JACOB_NAME"] = "ヤコブとエサウ", 
    ["#RUNE_SWORD_EIKA_NAME"] = "エイカ", 
 --ヘッドカノンの話になるのですが、またドレミー戦でもアイザックと呼ばれるように本人ではなくアイザックだと思っているため、漢字表記ではなくカタカナで他の「アイザック」に合わせました。
 --I(and Doremy) think so he is「isaac」not「eika ebisu」. So I expressed it in 「katakana」sorting 「isaac」s JP write .
    ["#RUNE_SWORD_SATORI_NAME"] = "サトリ", 
    ["#RUNE_SWORD_SEIJA_NAME"] = "セイジャ", 
    ["#RUNE_SWORD_SEIJA_REVERSED_NAME"] = "セイジャ", 
    
    ["#RUNE_SWORD_HAGALAZ_DESCRIPTION"] = "石の涙" ,
    ["#RUNE_SWORD_JERA_DESCRIPTION"] = "1+1+もっと" ,
    ["#RUNE_SWORD_EHWAZ_DESCRIPTION"] = "ボス部屋に隠された部屋" ,
    ["#RUNE_SWORD_DAGAZ_DESCRIPTION"] = "呪われない　+2ソウルハート" ,
    ["#RUNE_SWORD_ANSUZ_DESCRIPTION"] = "探検家" ,
    ["#RUNE_SWORD_PERTHRO_DESCRIPTION"] = "爆弾はダイスなり" ,
    --boms are keyの日本語訳、爆弾は鍵なりに合わせました。　sorting for 「boms are key」　in jp「bakudan wa kagi nari」
    ["#RUNE_SWORD_BERKANO_DESCRIPTION"] = "最後までおともだち！" ,
    ["#RUNE_SWORD_ALGIZ_DESCRIPTION"] = "ダメージでシールド" ,
    ["#RUNE_SWORD_BLANK_RUNE_DESCRIPTION"] = "ランダムルーン" ,
    ["#RUNE_SWORD_BLACK_RUNE_DESCRIPTION"] = "Allステータスアップ" ,
    ["#RUNE_SWORD_RUNE_SHARD_DESCRIPTION"] = "ランダムルーン" ,
    ["#RUNE_SWORD_ISAAC_DESCRIPTION"] = "より多くの運命" ,
    ["#RUNE_SWORD_MAGDALENE_DESCRIPTION"] = "濃厚な血" ,
    ["#RUNE_SWORD_CAIN_DESCRIPTION"] = "より多くのスペース" ,
    ["#RUNE_SWORD_JUDAS_DESCRIPTION"] = "カウンター暗殺" ,
    ["#RUNE_SWORD_BLUE_BABY_DESCRIPTION"] = "ナンバーツー" ,
    ["#RUNE_SWORD_EVE_DESCRIPTION"] = "群れの反撃" ,
    ["#RUNE_SWORD_SAMSON_DESCRIPTION"] = "ベルセルク!" ,
    ["#RUNE_SWORD_AZAZEL_DESCRIPTION"] = "太古の怒り" ,
    ["#RUNE_SWORD_LAZARUS_DESCRIPTION"] = "蘇る" ,
    ["#RUNE_SWORD_EDEN_DESCRIPTION"] = "ランダムなアイテム" ,
    ["#RUNE_SWORD_LOST_DESCRIPTION"] = "聖なる守り" ,
    ["#RUNE_SWORD_LILITH_DESCRIPTION"] = "我が子を受け入れよ" ,
    ["#RUNE_SWORD_KEEPER_DESCRIPTION"] = "カネ　カネ　カネ" ,
    ["#RUNE_SWORD_APOLLYON_DESCRIPTION"] = "群衆の編隊" ,
    ["#RUNE_SWORD_FORGOTTEN_DESCRIPTION"] = "あなたを殺さないものはあなたを強くする" ,
    ["#RUNE_SWORD_BETHANY_DESCRIPTION"] = "ウィスプコレクター" ,
    ["#RUNE_SWORD_JACOB_DESCRIPTION"] = "私の言ったとおりに" ,
    ["#RUNE_SWORD_EIKA_DESCRIPTION"] = "血の復活", 
    ["#RUNE_SWORD_SATORI_DESCRIPTION"] = "支配する涙", 
    ["#RUNE_SWORD_SEIJA_DESCRIPTION"] = "弱者による支配", 
    ["#RUNE_SWORD_SEIJA_REVERSED_DESCRIPTION"] = "強者の陥落", 

    ["#CELLPHONE_PURCHASE_TITLE"] = "お買い上げありがとうございます!",
    ["#CELLPHONE_PURCHASE_DESCRIPTION"] ="商品は配送中です!",
    
    ["#PAGES"] = "ページ",

    ["#REPAY_NOT_FINISHED"] = " {REPAYMENT}¢返済, のこりは{REMAINED}¢",
    ["#REPAY_FINISHED"] = " {REPAYMENT}¢返済, 完済した",

    ["#FOX_IN_TUBE_ESCAPE"] = "まさか出られるなんて！",
    ["#FOX_IN_TUBE_TREASURE_HELP_1"] = "気に入らない?", 
    ["#FOX_IN_TUBE_TREASURE_HELP_2"] = "運命を変えてしまえばいいわ!",
    ["#FOX_IN_TUBE_SACRIFICE_HELP_1"] = "天使に会いに行ったら", 
    ["#FOX_IN_TUBE_SACRIFICE_HELP_2"] = "いいと思う！",
    ["#FOX_IN_TUBE_SACRIFICE_HELP_3"] = "決定！",
    ["#FOX_IN_TUBE_SHOP_HELP_1"] = "いつ買うか?", 
    ["#FOX_IN_TUBE_SHOP_HELP_2"] = "今でしょ！",
    ["#FOX_IN_TUBE_CHALLENGE_HELP_1"] = "自分の限界に", 
    ["#FOX_IN_TUBE_CHALLENGE_HELP_2"] = "チャレンジしたい?", 
    ["#FOX_IN_TUBE_CHALLENGE_HELP_3"] = "好きにしたら？",
    ["#FOX_IN_TUBE_DEVIL_HELP_1"] = "命を置いて", 
    ["#FOX_IN_TUBE_DEVIL_HELP_2"] = "行きたくない？", 
    ["#FOX_IN_TUBE_DEVIL_HELP_3"] = "気にしないで、貰っちゃえ！",
    ["#FOX_IN_TUBE_ANGEL_HELP_1"] = "1つだけなんて", 
    ["#FOX_IN_TUBE_ANGEL_HELP_2"] = "とんだケチね･･･",
    ["#FOX_IN_TUBE_ANGEL_HELP_3"] = "気に入ったものを貰いなさい",
    ["#FOX_IN_TUBE_SECRET_HELP_1"] = "隠し部屋のアイテム?", 
    ["#FOX_IN_TUBE_SECRET_HELP_2"] = "ここにあるわ",
    
    ["#FOX_IN_TUBE_TREASURE_PAY_1"] = "これから先", 
    ["#FOX_IN_TUBE_TREASURE_PAY_2"] = "手に入れるものを", 
    ["#FOX_IN_TUBE_TREASURE_PAY_3"] = "先取りしたって感じ",
    ["#FOX_IN_TUBE_SACRIFICE_PAY_1"] = "悪魔からの祝福を賜ったの？",
    ["#FOX_IN_TUBE_SACRIFICE_PAY_2"] = "このケダモノ！",
    ["#FOX_IN_TUBE_SHOP_PAY_1"] = "アイツからお金", 
    ["#FOX_IN_TUBE_SHOP_PAY_2"] = "巻き上ようなんて思わないことね",
    ["#FOX_IN_TUBE_SHOP_PAY_3"] = "ドロボーさん!",
    ["#FOX_IN_TUBE_CHALLENGE_PAY_1"] = "さあ！", 
    ["#FOX_IN_TUBE_CHALLENGE_PAY_2"] = "臆病者なんて言われたくないでしょ！",
    ["#FOX_IN_TUBE_DEVIL_PAY_1"] = "悪魔から", 
    ["#FOX_IN_TUBE_DEVIL_PAY_2"] = "アイテムを盗む?", 
    ["#FOX_IN_TUBE_DEVIL_PAY_3"] = "どうやって？",
    ["#FOX_IN_TUBE_ANGEL_PAY_1"] = "ああっ、神さまっ！ ", 
    ["#FOX_IN_TUBE_ANGEL_PAY_2"] = "めっちゃ怒ってるじゃない!", 
    ["#FOX_IN_TUBE_ANGEL_PAY_3"] = "欲出さないほうがいいわね", 
    ["#FOX_IN_TUBE_SECRET_PAY_1"] = "あーらら", 
    ["#FOX_IN_TUBE_SECRET_PAY_2"] = "素晴らしく運が無いわね君",
--イコールでないことを踏まえて「菅牧典」に寄せて女性口調にしてますが、あまりキャラへの解像度が高くなく言語版のニュアンスに近いか微妙です。
--(maybe)neard kudamaki

    ["#YAMAWARO_CRATE_TITLE"] = "木箱",
    ["#YAMAWARO_CRATE_ITEMS"] = "アイテム",
    ["#YAMAWARO_CRATE_PAGE"] = "{CURRENT}/{ALL}",

    ["#MAGATAMA_ERROR"] = "!\"Division by Zero\" Attack!",
--エラー感を出すために訳しませんでした。怠惰じゃないです。
--protected error atmosphere. not translatied.


    ["#SPELL_CARD_UNKNOWN"] = "404 Spell Card not found",
    ["#SPELL_CARD_SCARLET_NIGHTMARE"] = "夢符「緋色の悪夢」",
    ["#SPELL_CARD_OCHRE_CONFUSION"] = "夢符「刈安色の迷夢」",
    ["#SPELL_CARD_DREAM_EXPRESS"] = "超特急「ドリームエクスプレス」",
    ["#SPELL_CARD_DREAM_CATCHER"] = "夢符「ドリームキャッチャー」",
    ["#SPELL_CARD_BUTTERFLY_SUPPLANTATION"] = "胡蝶「バタフライサプランテーション」",
    ["#SPELL_CARD_CREEPING_BULLET"] = "這夢「クリーピングバレット」",
    ["#SPELL_CARD_ULTRAMARINE_LUNATIC_DREAM"] = "月符「紺色の狂夢」",
    
    ["#DOREMY_ENDING_TITLE"] = "Thanks for playing!",
    ["#DOREMY_ENDING_SUBTITLE"] = "アイザックは幸せに暮らしましたとさ･･･",

    ["#COLLECTED_MUSIC"] = "聞こえたメロディ: {{CURRENT}}/{{MAX}}",

}

Translation.Dialogs = {
--アイザックのセリフはアイテム入手時よりも日記やメニューの紙に合わせ、なるべく漢字を控えました。#DOREMY_OUTRO_3が特に自信がありません。
--ドレミーのセリフは紺珠伝3面への参照をなるべく汲んだつもりです。
--霊夢に関しては適当ながらも面倒見はいいように書きました。
--isaac:child. based「hiragana」
--doremy:based TH15-3.
--reimu:halfhearted. but caring 
    ["#DOREMY_INTRO_1"] = "かわいそうなアイザック{WAIT:10} どんな夢を見ているの...",
    ["#DOREMY_INTRO_2"] = "ここはどこ?{WAIT:20} キミはだれ?",
    ["#DOREMY_INTRO_3"] = "夢の世界にようこそ.",
    ["#DOREMY_INTRO_4"] = "私はドレミー　夢の世界の支配者です.",
    ["#DOREMY_INTRO_5"] = "ボクはどうしてここに?",
    ["#DOREMY_INTRO_6"] = "あなたは死にました。私はあなたを別の世界に連れて行くためにここにいます。",
    ["#DOREMY_INTRO_7"] = "ボク、死んだの?でもどうして...",
    ["#DOREMY_INTRO_8"] = "ぜんぶマボロシだったの?",
    ["#DOREMY_INTRO_9"] = "あたまがいたい...どうしたんだろう...?",
    ["#DOREMY_INTRO_10"] = "見たところ、あなたは恐ろしい悪夢に縛られている･･･",
    ["#DOREMY_INTRO_11"] = "その悪夢、私が処理します。",
    ["#DOREMY_INTRO_12"] = "私と戦い、勝ち残って見せてください。",
    ["#DOREMY_INTRO_13"] = "大丈夫、すぐに安全に目覚められますよ。",
    ["#DOREMY_INTRO_14"] = "さあ、始めましょう",
    ["#DOREMY_OUTRO_1"] = "ふう･･･{WAIT:20} 悪夢は処理させて頂きました.",
    ["#DOREMY_OUTRO_2"] = "ドレミー... ボクこれからどうしたらいいの?",
    ["#DOREMY_OUTRO_3"] = "ママも {WAIT:15}パパも...{WAIT:15}ボクもワルいひとなんだ･･･",
    ["#DOREMY_OUTRO_4"] = "気にしないで {WAIT:5}アイザック {WAIT:15}それはあなたのせいじゃないわ",
    ["#DOREMY_OUTRO_5"] = "あなたは罪のない･･･{WAIT:15}純粋な子供なんだから。",
    ["#DOREMY_OUTRO_6"] = "もしもまた悪い事があったら {WAIT:15}夢に私を探しに来て。",
    ["#DOREMY_OUTRO_7"] = "出来る限り助けになりますよ。 {WAIT:15}だからいい子でいてね、 {WAIT:10}わかった?",
    ["#DOREMY_OUTRO_8"] = "うん...",
    ["#DOREMY_OUTRO_9"] = "いい返事ね {WAIT:5}アイザック。 {WAIT:15}さあ、その時が来ました。",
    ["#DOREMY_OUTRO_10"] = "今は眠りなさい. {WAIT:15}あなたの槐安は, {WAIT:10}これから作られる...",

    
    ["#DOREMY_ENDING_1"] = "...やっと目を覚ましたのね、 {WAIT:20}ちびすけ。",
    ["#DOREMY_ENDING_2"] = "ここはどこ?",
    ["#DOREMY_ENDING_3"] = "ここは博麗神社。",
    ["#DOREMY_ENDING_4"] = "私は霊夢 {WAIT:20}ここで巫女をしているわ。",
    ["#DOREMY_ENDING_5"] = "夢で迷子がここに来るから世話しろって･･･",
    ["#DOREMY_ENDING_6"] = "すごい簡単に押し付けてきたけどねー。",
    ["#DOREMY_ENDING_7"] = "はぁ...{WAIT:20}何でも押し付けてくるなって感じよ。",
    ["#DOREMY_ENDING_8"] = "レイム、 {WAIT:20}ぼくこれからどうなるの？...?",
    ["#DOREMY_ENDING_9"] = "あなたは幻想郷の人里で暮らすことになる。",
    ["#DOREMY_ENDING_10"] = "ただ･･･{WAIT:20}家を探すところからになるわね。",
    ["#DOREMY_ENDING_11"] = "見つかるまでは神社に置いておいても構わないけど。",
    ["#DOREMY_ENDING_12"] = "うん...",
    ["#DOREMY_ENDING_13"] = "ほら、 {WAIT:20}家探しに行くわよ。",
    ["#DOREMY_ENDING_14"] = "幻想郷へようこそ、 {WAIT:20}ここは全てを受け入れてくれる...",
    ["#DOREMY_ENDING_15"] = "また夢で逢いましょう...",
}

local Collectibles = THI.Collectibles;
Translation.Collectibles ={
    [Collectibles.YinYangOrb.Item] = {Name="躍る陰陽玉" , Description="跳ねて暴れる"},
    [Collectibles.DarkRibbon.Item] = {Name="闇のリボン" , Description="闇の中で"},
    [Collectibles.DYSSpring.Item] = {Name="大妖精の泉" , Description="妖精の祝福"},
    [Collectibles.DragonBadge.Item] = {Name="虹龍紋" , Description="FIGHT！"},
    [Collectibles.Koakuma.Item] = {Name="小悪魔ベイビー" , Description="本の悪魔"},
    [Collectibles.Grimoire.Item] = {Name="グリモワールオブパチュリー" , Description="七曜の書"},
--グリモワールオブシリーズへの参照をくみ取りました。
--Description neard「grimore of」series(marisa/usami).
    [Collectibles.MaidSuit.Item] = {Name="メイド服" , Description="完全で瀟洒"},
    [Collectibles.VampireTooth.Item] = {Name="吸血鬼の牙" , Description="運命を受け入れろ"},
    [Collectibles.Destruction.Item] = {Name="破滅" , Description="大災害"},
--Changed 破壊 to 破滅.
    [Collectibles.MarisasBroom.Item] = {Name="魔法のほうき" , Description="キノコの数はパワーだぜ"},
--「弾幕はパワーだぜ」への参照です。
--Description  Reference「danmaku is power」
    [Collectibles.FrozenSakura.Item] = {Name="凍った桜" , Description="春の雪"},
    [Collectibles.ChenBaby.Item] = {Name="赤ちぇん" , Description="ちぇぇぇぇん！！！！！"},
--baby→赤ちゃん+橙（ちぇん）
--Description is baby→aka[chan] + [chen]
    [Collectibles.ShanghaiDoll.Item] = {Name="上海人形" , Description="私のそれとは違います……"},
--Modified descrption from "なんか違くない……？" to "私のそれとは違います……".
    [Collectibles.MelancholicViolin.Item] = {Name="憂奏バイオリン" , Description="調律トーテム"},
--「〇奏」で揃えたかったのですが、「憂奏」は造語になります。　プリズムリバートーテムは解説がちょっと不安です。
--plism totem name algining 「~sou」　but「yuusou」is original word.  Description bad translated...
    [Collectibles.ManiacTrumpet.Item] = {Name="狂奏トランペット" , Description="積極トーテム"},
    [Collectibles.IllusionaryKeyboard.Item] = {Name="幻奏トランペット" , Description="多動トーテム"},
    [Collectibles.DeletedErhu.Item] = {Name="■■二胡" , Description="未実装"},
--「削除された」というより「実装されなかった」というニュアンスにしました。　
--「Delited」→「Unused」「Cutting contents」
    [Collectibles.Roukanken.Item] = {Name="楼観剣" , Description="六観の剣をくらえ！"},
    [Collectibles.FanOfTheDead.Item] = {Name="センスオブザデッド" , Description="ボーダーオブライフ"},
--「センスオブエレガンス」に寄せました。
--Reference｢sense(sensu(=fan))) of elegance｣ from TH12.3
    [Collectibles.FriedTofu.Item] = {Name="油揚げ" , Description="キツネが好きなやーつ"},
--おおむね意味は変わりませんが、「〇〇なやーつ」は日本で若干流行った言い回しです。  
--「~ na yarts」is japanise yonger wording
    [Collectibles.OneOfNineTails.Item] = {Name="九尾の一尾" , Description="式神召喚、数は力"},
--入手時とフロア毎に使い魔を出す効果と使い魔の数でのステータスアップの双方に言及しました。
--Reference summoning famillia efect and Get stronger by number of famillia efect.
--「shikigami shokan kazu wa tikara(summon fammilia and number is power)」
    [Collectibles.Gap.Item] = {Name="スキマ" , Description="空間の境界"},

    [Collectibles.Starseeker.Item] = {Name="スターシーカー" , Description="未来を眺める"},
    [Collectibles.Pathseeker.Item] = {Name="パスシーカー" , Description="世界を眺める"},
--秘封俱楽部はあまり自信がありませんが、双方を合わせる感覚は汲みました。
--hifuu quoted item is  involving  maybe bad translated...

    [Collectibles.GourdShroom.Item] = {Name="萃霊茸" , Description="ちびでか気分"},
--「萃霊花」に寄せました。
--Reference 「suireika」 from TH11
    [Collectibles.JarOfFireflies.Item] = {Name="ホタルの瓶" , Description="ほ～たる来い"},
--海外の楽曲への参照のような気がしましたが、日本に「ほたる来い」という歌があり、それに寄せました。
--original translate Reference by song?  this translation Reference is japanise trad song「hotaru koi(come fireflies)」
    [Collectibles.SongOfNightbird.Item] = {Name="夜雀の歌" , Description="もう歌しか聞こえない"},
    [Collectibles.BookOfYears.Item] = {Name="歴史の本" , Description="過去改変"},
    [Collectibles.RabbitTrap.Item] = {Name="うさぎトラップ" , Description="足元注意！"},
    [Collectibles.Illusion.Item] = {Name="イリュージョン" , Description="何を隠しているの？！"},
--Changed description from "どこいった？！" to "何を隠しているの？！"
    [Collectibles.PeerlessElixir.Item] = {Name="国士無双の薬" , Description="用法容量を守って正しくお使い下さい"},
--日本の薬は薬事法などでこのように表記されます。若干ネタとしても扱われます。
    [Collectibles.DragonNeckJewel.Item] = {Name="龍の頸の玉" , Description="五色の弹丸"},
    [Collectibles.RobeOfFirerat.Item] = {Name="火鼠の皮衣" , Description="焦れぬ心"},
    [Collectibles.BuddhasBowl.Item] = {Name="仏の御石の鉢" , Description="砕けぬ意志"},
    [Collectibles.SwallowsShell.Item] = {Name="燕の子安貝" , Description="永命線"},
    [Collectibles.JeweledBranch.Item] = {Name="蓬莱の玉の枝" , Description="虹色の弹幕"},
    [Collectibles.AshOfPhoenix.Item] = {Name="フェニックスの灰" , Description="涅槃"},

    
    [Collectibles.TenguCamera.Item] = {Name="天狗のカメラ" , Description="はいチーズ！"},
    [Collectibles.SunflowerPot.Item] = {Name="ひまわりの鉢" , Description="傷つけないで！"},
    [Collectibles.ContinueArcade.Item] = {Name="コンティニュー？" , Description="いくら出す？"},
--これは小町への参照アイテムですが、日本ではコンティニューはどちらかと言えばフランドールに関連付けされる傾向があります。どちらの訳も紅魔郷EXを意識しています。
--復活時に要求コインが増える点への言及でもあります。
--this item Reference is komachi. but 「continue」 in jp Reference is flan. Description from TH6-EX.
    [Collectibles.RodOfRemorse.Item] = {Name="懺悔の棒" , Description="悔い改め、犠牲となれ"},

    [Collectibles.IsaacsLastWills.Item] = {Name="アイザックの遺言" , Description="きょうぼくは死にました"},
--  [Collectibles.IsaacsLastWills.Item] = {Name="にっきさん" , Description="きょうぼくは死にました"},
--上は直訳、下は「dear dialy」の日本における訳です。
--comentouted name Reference is lastwills writing「dear dialy」in JP　「nikki san he(for mr'dialy)」
    [Collectibles.SunnyFairy.Item] = {Name="日の光の妖精" , Description="私はサニー！"},
    [Collectibles.LunarFairy.Item] = {Name="月の光の妖精" , Description="私はルナ！"},
    [Collectibles.StarFairy.Item] = {Name="星の光の妖精" , Description="私はスター！"},
    
    [Collectibles.LeafShield.Item] = {Name="リーフシールド" , Description="ヲ　ソウビ　シマシタ"},
-- Removed "-W-"
    [Collectibles.BakedSweetPotato.Item] = {Name="やきいも" , Description="ホクホクで甘い！"},
    [Collectibles.BrokenAmulet.Item] = {Name="壊れたお守り" , Description="みんな不吉なカンジ･･･"},
    [Collectibles.ExtendingArm.Item] = {Name="のびーるアーム" , Description="掴んで離すな！"},
    [Collectibles.WolfEye.Item] = {Name="白狼の眼" , Description="千里眼"},
    [Collectibles.Benediction.Item] = {Name="祈祷" , Description="神降ろし"},
    [Collectibles.Onbashira.Item] = {Name="御柱" , Description="フォーリングオンバシラ"},
--「ライジングオンバシラ」に寄せました。
--Reference「Rising onbashira」from TH14.3
    [Collectibles.YoungNativeGod.Item] = {Name="土着神の分霊" , Description="土地精霊"},
--[Collectibles.YoungNativeGod.Item] = {Name="若き土着神" , Description="土地精霊"},
--無理やりです。日本特有かもしれませんが、「分霊」という考え方があります。別の土地で同じ神を祀るとき、その魂を分けるそうです。
--自分はこのアイテムを「若い土地神」以上に「諏訪子(かほかの土地神)の分霊」と考えました。下の訳は直訳です。ニュアンスにあわせて頂ければ。
--japan sindou 「wakemitama(bunrei)」system is branching gods soul. nearing is this item.
--i think  this item is「suwako(or other native god)'s wakemitama」　
    [Collectibles.GeographicChain.Item] = {Name="ジオグラフィーチェーン" , Description="運アップ、お前の前に立つものはいない！"},
    [Collectibles.RuneSword.Item] = {Name="ルーンソード" , Description="石の声"},
    [Collectibles.Escape.Item] = {Name="脱兎のごとく" , Description="逃げるは恥だが役に立つ"},
--「脱兎のごとく」は「逃げる兎のように素早く」という意味です。逃げ恥ネタは説明に集約させました。
--「Datto no gotoku(Like a escaping rabbit)」is「very nimble,fast」.「nigehazi」 is full included Description
    [Collectibles.Keystone.Item] = {Name="要石" , Description="再利用可能地震"},
    [Collectibles.AngelsRaiment.Item] = {Name="天の羽衣" , Description="天からの復讐"},



    [Collectibles.BucketOfWisps.Item] = {Name="バケツ一杯のウィスプ" , Description="魂を燃やせ"},
    [Collectibles.PlagueLord.Item] = {Name="プレイグロード" , Description="悪魔の毒々感染症"},
--無理やりです。「The Toxic Avenger」という映画があり、その日本語訳が「悪魔の毒々モンスター」といい、それへの参照です。
--しいて言えば、「Toxic Shock」の日本での解説が「毒がドクドク！」であり、それに寄せた感じです。
--Description from 「The Toxic Avenger」 in JP「akuma no dokudoku monster(evil toxic monster)」　neard「Toxic Shock」s Description in jp「doku(poison) ga dokudoku!」
    [Collectibles.GreenEyedEnvy.Item] = {Name="グリーンアイドエンヴィー" , Description="妬ましい･･･"},
    [Collectibles.OniHorn.Item] = {Name="鬼の角" , Description="三步必殺"},
    [Collectibles.PsycheEye.Item] = {Name="サイキックアイ" , Description="全てはさとり様のために"},
    [Collectibles.GuppysCorpseCart.Item] = {Name="ガッピーの猫車" , Description="敵 轢きてえなあああああああ！！！"},
--初出を失念してしまったのですが(アニメ「PSYCHO-PASS」かも)、あ゛あ゛あ゛あ゛あ゛あ゛あ゛！！！人　轢きてえなあああああああ！！！轢きてえよおおおおおおおおおおお！！！
--というボイスが一部で流行してました。
--Reference litte meme voice　by...forget(maybe PSYCHO-PASS)「A U G H H H H H !!! I Want Run Overrrrrr!!! I WAAAAAAAAAANT!!!」
    [Collectibles.Technology666.Item] = {Name="テクノロジー666" , Description="地獄の技術"},
    [Collectibles.PsychoKnife.Item] = {Name="サイコナイフ" , Description="あ　な　た　の　う　し　ろ　に"},
--包丁はアイザック含め何かとインディーズゲームと縁深いですが、名前のこのひらがな表記は「ゆめにっき」が基になってます。二次創作にはなりますが、よくこいしと絡められています。
--name nearing is yume nikki    koisi in yume nikki mixed fanfic is common

--Changed the name from "ほうちょう" to "サイコナイフ", tt's a reference to Terraria.
    [Collectibles.DowsingRods.Item] = {Name="ダウジングロッド" , Description="おたから発掘"},
    [Collectibles.ScaringUmbrella.Item] = {Name="こわーい傘" , Description="笑うな！"},
    [Collectibles.Unzan.Item] = {Name="雲山" , Description="問答無用の妖怪拳！"},
    [Collectibles.Pagota.Item] = {Name="宝塔" , Description="ピッカピカ！"},
    [Collectibles.SorcerersScroll.Item] = {Name="エア巻物" , Description="身体強化"},
    [Collectibles.SaucerRemote.Item] = {Name="リモコンUFO" , Description="来襲！"},

    [Collectibles.TenguCellphone.Item] = {Name="天狗のケータイ" , Description="検索検索ぅ！"},
    [Collectibles.EtherealArm.Item] = {Name="見えざる腕" , Description="他には何も尋ねないで下さい"},
--解説は「super malio 64 anti piracy screen」のフェイク動画の一つへの参照です。
--Description　Reference「super malio 64 anti piracy screen」face videos one
    
    [Collectibles.MountainEar.Item] = {Name="山彦ーっ！" , Description="山彦ーっ！彦ーっ！･･･っ！"},
--山彦の小さくなっていく感じを表現する方向に寄せました。　include echo smalling
    [Collectibles.ZombieInfestation.Item] = {Name="ゾンビハザード" , Description="バイオハザード"},
    [Collectibles.WarpingHairpin.Item] = {Name="通り抜けヘアピン" , Description="壁の向こうはなんだろな？"},
    [Collectibles.HolyThunder.Item] = {Name="ホーリーサンダー" , Description="天からの鉄槌"},
    [Collectibles.GeomanticDetector.Item] = {Name="風水検知器" , Description="ラッキープレイスみっけ！"},
    [Collectibles.Lightbombs.Item] = {Name="ライト爆弾" , Description="爆弾+5，天からの光が汝を焼き尽くす！"},
    [Collectibles.D2147483647.Item] = {Name="D2147483647" , Description="こいつは化ける"},
--化けるは「姿を変える」の他に「可能性がある」などの意味で使われます。
--「bakeru」 is　「transform」beside「have Potential」
    [Collectibles.EmptyBook.Item] = {Name="白紙の本" , Description="何を書こうかな？"},

    [Collectibles.TheInfamies.Item] = {Name="悪名たち" , Description="脆き者よ、汝の名は心"},
--解説に自信が無いです。Description bad translated...

--Changed the description from "壊れやすい、その名はこころ" to "脆き者よ、汝の名は心", Hamlet reference.
    [Collectibles.SekibankisHead.Item] = {Name="赤蛮奇" , Description="カワイかろ？"},
    [Collectibles.WildFury.Item] = {Name="野性の怒り" , Description="血にまみれて育つ"},
    [Collectibles.ReverieMusic.Item] = {Name="「幻想浄瑠璃」" , Description="なんだろう……？"},
--「結果」に寄せました。 name from　music corect Result
    [Collectibles.DFlip.Item] = {Name="Dフリップ" , Description="すえかりくっひ"},
--ひらがなの上下反転が表現しきれませんでした。反対側に書くので許してください。
--sorry!hiragana is impossible up side down.
    [Collectibles.MiracleMallet.Item] = {Name="打ち出の小づち" , Description="きみの願いは？"},
    [Collectibles.ThunderDrum.Item] = {Name="カミナリ太鼓" , Description="ドラムを打ち鳴らせ"},
    [Collectibles.NimbleFabric.Item] = {Name="ひらり布" , Description="押しっぱなしで再使用可能ひらり"},
    [Collectibles.MiracleMalletReplica.Item] = {Name="打ち出の小づち（レプリカ）" , Description="はい、ドーン！"},

    [Collectibles.RuneCape.Item] = {Name="ルーンマント" , Description="ショットスピードアップ、ミライモミエマス"},
    [Collectibles.THTRAINER.Item] = {Name="バグ技" , Description="th14.exe catastrophic failure"},

    [Collectibles.LunaticGun.Item] = {Name="ルナティックガン" , Description="異次元からの手助け"},
    [Collectibles.ViciousCurse.Item] = {Name="悪い呪い" , Description="あなたが刺されて死ねばいいのに"},
    [Collectibles.CarnivalHat.Item] = {Name="カーニバルハット" , Description="ルナティックタイム！"},
    [Collectibles.PureFury.Item] = {Name="ピュアフューリー" , Description="DMGアップ"},
    [Collectibles.Hekate.Item] = {Name="ヘカテー" , Description="惑星を従える"},


    [Collectibles.DadsShares.Item] = {Name="パパの株" , Description="確実に儲かる方法！"},
    [Collectibles.MomsIOU.Item] = {Name="ママの信用書" , Description="お金！でもどこから･･･？"},

    [Collectibles.YamanbasChopper.Item] = {Name="山姥の鉈" , Description="善悪"},
    [Collectibles.GolemOfIsaac.Item] = {Name="ゴーレムザック" , Description="そっくりさん"},
    [Collectibles.DancerServants.Item] = {Name="ダンサーバント" , Description="ダンス・ダンス・ダンス"},
--名前は「かばん語」にしました。また解説は日本にある同名の小説への参照にしました。
--name is Portmanteau word:「dancer」+「servant」(Dancervant) . Description from novel「Dance Dance Dance」 by　haruki murakami
    [Collectibles.BackDoor.Item] = {Name="バックドア" , Description="弾を削る"},

    [Collectibles.FetusBlood.Item] = {Name="胎児の血" , Description="よみがえれ"},
--re「bone」を日本語で表現しきれませんでした。
--I 「re「bone」(reborn + bone) 」is not translated...
    [Collectibles.CockcrowWings.Item] = {Name="夜明けの翼" , Description="24時間戦えますか？"},
    [Collectibles.KiketsuBlackmail.Item] = {Name="鬼傑組からの脅迫状" , Description="従うか、死ぬか"},
    [Collectibles.CarvingTools.Item] = {Name="造形工具" , Description="埴輪兵団"},
    [Collectibles.BrutalHorseshoe.Item] = {Name="残忍な蹄鉄" , Description="ためて突進"},

    [Collectibles.Hunger.Item] = {Name="飢え" , Description="デザイアドライブ"},
--原曲に寄せ戻しました。 more neard 「desiar drive」
    [Collectibles.SakeOfForgotten.Item] = {Name="わすれ酒" , Description="わすれちゃった……"},
--全面的に自信がないです。 any bad translated...
    [Collectibles.GamblingD6.Item] = {Name="ギャンブルD6" , Description="大か小か"},
    [Collectibles.YamawarosCrate.Item] = {Name="山童の木箱" , Description="アイテム倉庫"},
    [Collectibles.DelusionPipe.Item] = {Name="妄想パイプ" , Description="喜びに溺れる"},
    [Collectibles.SoulMagatama.Item] = {Name="魂の勾玉" , Description="ライフ交換"},
    [Collectibles.FoxInTube.Item] = {Name="狐管" , Description="ウソなんて言えないよ？"},
-- [Collectibles.FoxInTube.Item] = {Name="狐管" , Description="簡単なことも教えてあげる"},
--「How Could I Lie To You?」という楽曲への参照であることはわかりますが、上手く訳に落とし込めず曲げて訳した感じです。
--下の訳は日本で作られた嘘と狐に関連する楽曲「フォニイ」への参照です。
--quote by 「How Could I Lie To You?」 isn't translated...
--commentouted Description from 「phony」have an element lie and fox song by tsumiki.
    [Collectibles.DaitenguTelescope.Item] = {Name="大天狗の望遠鏡" , Description="星が落ちる･･･"},
    [Collectibles.ExchangeTicket.Item] = {Name="交換所チケット" , Description="必要な物は･･･"},
--解説に自信がないです。 Description is bad translated...
    [Collectibles.CurseOfCentipede.Item] = {Name="ムカデの呪い" , Description="拡拡拡拡散散散散弾弾弾弾"},
    
    [Collectibles.RebelMechaCaller.Item] = {Name="反獄メカ発進" , Description="僕はこいつで行く"},
--名前訳に自信がないです。解説は「僕はガンダムで行く」に寄せました。
--name is bad translated... Description Reference ready player one「boku wa gundam de iku」
-- [Collectibles.DualDivision.Item] = {Name="二元分割" , Description="切裂命运"},
    [Collectibles.DSiphon.Item] = {Name="Dサイフォン" , Description="ちからをすいとる"},
--ポケットモンスターのわざ「ちからをすいとる」への参照です。ただしあちらは英語だと「Strength Sap」です。
--Description Reference pokemon　move「Strength Sap」in JP「chikara wo suitoru(power drain)」
    -- {Name="我的手册" , Description="这是我写的！"},
    -- {Name="我的指南" , Description="这是我写的！"},
    -- {Name="我的史书" , Description="这是我写的！"},
    [Collectibles.DreamSoul.Item] = {Name="夢魂" , Description="目覚めよ"},

    [Collectibles.FairyDust.Item] = {Name="妖精の塵" , Description="飛び立つ願い"},
    [Collectibles.SpiritCannon.Item] = {Name="気功砲" , Description="新気功砲ぉぉぉぉぉぉぉ！！！"},
    [Collectibles.DaggerOfServants.Item] = {Name="従者の刃" , Description="あなたの心を犠牲にして"},
    [Collectibles.Asthma.Item] = {Name="ぜんそく" , Description="魔法アップ、再生ダウン"},

    [Collectibles.EyeOfChimera.Item] = {Name="キメラの目" , Description="未知の運命を探る"},
    
}

local Trinkets = THI.Trinkets;
Translation.Trinkets ={
    [Trinkets.FrozenFrog.Trinket] = {Name="凍ったカエル" , Description="アイスタッチ"},
    [Trinkets.AromaticFlower.Trinket] = {Name="アロマフラワー" , Description="春なら2回死ねる"},
    [Trinkets.GlassesOfKnowledge.Trinket] = {Name="知識のメガネ" , Description="アイテムごとに全ステータスアップ"},
    [Trinkets.HowToReadABook.Trinket] = {Name="本を読む本" , Description="読書家をめざす人へ"},
--日本にでの外山滋比古・槇未知子による訳版より。
--from Translated ver title by toyama shigehiko and maki michiko.
    [Trinkets.CorrodedDoll.Trinket] = {Name="どくどく人形" , Description="さわるな危険！"},
    [Trinkets.GhostAnchor.Trinket] = {Name="ゴーストアンカー" , Description="正当防衛"},
    [Trinkets.ButterflyWings.Trinket] = {Name="胡蝶の翅" , Description="夢は現実、現実は夢"},
    [Trinkets.LionStatue.Trinket] = {Name="狛犬" , Description="一対の神獣"},
    [Trinkets.FortuneCatPaw.Trinket] = {Name="招き猫の前足" , Description="千客万来"},
    [Trinkets.MermanShell.Trinket] = {Name="人魚の貝殻" , Description="水、ズルイ。"},
--日本で作られた水道水啓発CM「水道水ガール」への参照です。ニコニコ動画で狭いミームを持っています。
--Description　Reference Japanise Tapwater CM「Suidousui Girl」 in nikoniko little meme 「Suidousui zurui(Tapwarter is OP)」
    [Trinkets.Dangos.Trinket] = {Name="おだんご" , Description="MGMG"},
--立ち絵に寄せました。 Description Reference　Ringo's portrait
    [Trinkets.BundledStatue.Trinket] = {Name="おくるみ石像" , Description="ハイグラビティー"},
    [Trinkets.ShieldOfLoyalty.Trinket] = {Name="忠義の盾" , Description="我々はあなたの盾"},
    [Trinkets.SwordOfLoyalty.Trinket] = {Name="忠義の剑" , Description="あなたに忠誠を誓います"},

    [Trinkets.Snowflake.Trinket] = {Name="雪片" , Description="ユニークでパーフェクト"},
    [Trinkets.HeartSticker.Trinket] = {Name="ハート形シール" , Description="<3"},

}

local Players = THI.Players;
Translation.Players ={
    [Players.Eika.Type] = {Name="エイカ" , Birthright="塵も積もれば山となる"},
    [Players.EikaB.Type] = {Name="エイカ" , Birthright="死体が爆発四散"},
    [Players.Satori.Type] = {Name="サトリ" , Birthright="恐るべき催眠術"},
    [Players.SatoriB.Type] = {Name="サトリ" , Birthright="天に任せる"},
    [Players.Seija.Type] = {Name="セイジャ" , Birthright="弱者の反乱"},
    --この「はんらん」は(圧力で虐げられていたものが）逆襲する、のような意味です。
    --this 「hanran」is「avenged」
    --[Players.SeijaB.Type] = {Name="セイジャ" , Birthright="弱者の氾濫"},
    [Players.SeijaB.Type] = {Name="セイジャ" , Birthright="サイホン制御"}, -- Sorry but this effect has been changed
    --この「はんらん」は広がって増えていく、のような意味です。
    --this 「hanran」is「increased」
}

local Cards = THI.Cards;
Translation.Cards ={
    [Cards.SoulOfEika.ID] = {Name="エイカのソウル" , Description="骨の願い"},
    [Cards.SoulOfSatori.ID] = {Name="サトリのソウル" , Description="あなたが私のマスター"},
--Fateへの参照です。前後を切る事で断言させました。Description Reference fate/stay night
    [Cards.ASmallStone.ID] = {Name="小石" , Description="一重積んでは･･･"},
    [Cards.SpiritMirror.ID] = {Name="スピリットミラー" , Description="共食い"},
    [Cards.SoulOfSeija.ID] = {Name="セイジャのソウル" , Description="フリップ"},
    [Cards.SoulOfSeija.ReversedID] = {Name="セイジャのソウル" , Description="フリップ"},
    [Cards.SituationTwist.ID] = {Name="形勢逆転" , Description="リロールしてシャッフル"}
}
local Pills = THI.Pills;
Translation.Pills ={
    [Pills.PillOfUltramarineOrb.ID] = {Name="紺珠の薬" },
}

return Translation;
