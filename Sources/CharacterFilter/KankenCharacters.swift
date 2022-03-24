//
//  File.swift
//  
//
//  Created by Morten Bertz on 2021/11/08.
//

import Foundation

/// The Kanken (Kanji Aptitude Test) filter.
public enum KankenFilter:String, CharacterFiltering, Equatable, Codable, CaseIterable, Identifiable, CustomStringConvertible{
    
    case kanken10
    case kanken9
    case kanken8
    case kanken7
    case kanken6
    case kanken5
    case kanken4
    case kanken3
    case kankenPre2
    case kanken2
    case kankenPre1
    case kanken1
    
    
    public var disallowedCharacters: Set<String>{
        switch self {
        case .kanken10:
            return Set(KankenFilter.Kanken10Characters.map({String($0)}))
        case .kanken9:
            return KankenFilter.kanken10.disallowedCharacters.union(KankenFilter.Kanken9Characters.map({String($0)}))
        case .kanken8:
            return KankenFilter.kanken9.disallowedCharacters.union(KankenFilter.Kanken8Characters.map({String($0)}))
        case .kanken7:
            return KankenFilter.kanken8.disallowedCharacters.union(KankenFilter.Kanken7Characters.map({String($0)}))
        case .kanken6:
            return KankenFilter.kanken7.disallowedCharacters.union(KankenFilter.Kanken6Characters.map({String($0)}))
        case .kanken5:
            return KankenFilter.kanken6.disallowedCharacters.union(KankenFilter.Kanken5Characters.map({String($0)}))
        case .kanken4:
            return KankenFilter.kanken5.disallowedCharacters.union(KankenFilter.Kanken4Characters.map({String($0)}))
        case .kanken3:
            return KankenFilter.kanken4.disallowedCharacters.union(KankenFilter.Kanken4Characters.map({String($0)}))
        case .kankenPre2:
            return KankenFilter.kanken3.disallowedCharacters.union(KankenFilter.KankenPre2Characters.map({String($0)}))
        case .kanken2:
            return KankenFilter.kankenPre2.disallowedCharacters.union(KankenFilter.Kanken2Characters.map({String($0)}))
        case .kankenPre1:
            return KankenFilter.kanken2.disallowedCharacters.union(KankenFilter.KankenPre1Characters.map({String($0)}))
        case .kanken1:
            return KankenFilter.kankenPre1.disallowedCharacters.union(KankenFilter.Kanken1Characters.map({String($0)}))
        
        }
    }
    
    
    public var localizedName: String{
        let tableName = "Localizable"
        
        switch self {
        case .kanken10:
            return Bundle.module.localizedString(forKey: "Kanken 10", value: "Kanken Level 10", table: tableName)
        case .kanken9:
            return Bundle.module.localizedString(forKey: "Kanken 9", value: "Kanken Level 9", table: tableName)
        case .kanken8:
            return Bundle.module.localizedString(forKey: "Kanken 8", value: "Kanken Level 8", table: tableName)
        case .kanken7:
            return Bundle.module.localizedString(forKey: "Kanken 7", value: "Kanken Level 7", table: tableName)
        case .kanken6:
            return Bundle.module.localizedString(forKey: "Kanken 6", value: "Kanken Level 6", table: tableName)
        case .kanken5:
            return Bundle.module.localizedString(forKey: "Kanken 5", value: "Kanken Level 5", table: tableName)
        case .kanken4:
            return Bundle.module.localizedString(forKey: "Kanken 4", value: "Kanken Level 4", table: tableName)
        case .kanken3:
            return Bundle.module.localizedString(forKey: "Kanken 3", value: "Kanken Level 3", table: tableName)
        case .kankenPre2:
            return Bundle.module.localizedString(forKey: "Kanken Pre 2", value: "Kanken Level Pre-2", table: tableName)
        case .kanken2:
            return Bundle.module.localizedString(forKey: "Kanken 2", value: "Kanken Level 2", table: tableName)
        case .kankenPre1:
            return Bundle.module.localizedString(forKey: "Kanken Pre 1", value: "Kanken Level Pre-1", table: tableName)
        case .kanken1:
            return Bundle.module.localizedString(forKey: "Kanken 1", value: "Kanken Level 1", table: tableName)
        }
        
    }
    
    public init?(data: Data) {
        if let f=try? JSONDecoder().decode(KankenFilter.self, from: data){
            self=f
        }
        else{
            return nil
        }
    }
    
    public var id: String{
        return self.rawValue
    }
    
    public var description: String{
        return self.localizedName
    }
}

extension KankenFilter{
    static let Kanken10Characters = "一七三上下中九二五人休先入八六円出力十千口右名四土夕大天女子字学小山川左年手文日早月木本村林校森正気水火犬玉王生田男町白百目石空立竹糸耳花草虫見貝赤足車金雨青音"
    
    static let Kanken9Characters = "万丸交京今会体何作元兄光公内冬刀分切前北午半南原友古台合同回図国園地場声売夏外多夜太妹姉室家寺少岩工市帰広店弓引弟弱強当形後心思戸才教数新方明星春昼時晴曜書朝来東楽歌止歩母毎毛池汽活海点父牛理用画番直矢知社秋科答算米紙細組絵線羽考聞肉自船色茶行西親角言計記話語読谷買走近通週道遠里野長門間雪雲電頭顔風食首馬高魚鳥鳴麦黄黒"
    
    static let Kanken8Characters = "丁世両主乗予事仕他代住使係倍全具写列助勉動勝化区医去反取受号向君味命和品員商問坂央始委守安定実客宮宿寒対局屋岸島州帳平幸度庫庭式役待急息悪悲想意感所打投拾持指放整旅族昔昭暑暗曲有服期板柱根植業様横橋次歯死氷決油波注泳洋流消深温港湖湯漢炭物球由申界畑病発登皮皿相県真着短研礼神祭福秒究章童笛第筆等箱級終緑練羊美習者育苦荷落葉薬血表詩調談豆負起路身転軽農返追送速進遊運部都配酒重鉄銀開院陽階集面題飲館駅鼻"
    
    static let Kanken7Characters = "不争付令以仲伝位低例便信倉候借停健側働億兆児共兵典冷初別利刷副功加努労勇包卒協単博印参史司各告周唱喜器囲固型堂塩士変夫失好季孫完官害察巣差希席帯底府康建径徒得必念愛成戦折挙改救敗散料旗昨景最望未末札材束松果栄案梅械極標機欠歴残殺毒氏民求治法泣浅浴清満漁灯無然焼照熱牧特産的省祝票種積競笑管節粉紀約結給続置老胃脈腸臣航良芸芽英菜街衣要覚観訓試説課議象貨貯費賞軍輪辞辺連達選郡量録鏡関陸隊静順願類飛飯養験"
    
    static let Kanken6Characters = "久仏仮件任似余価保修俵個備像再刊判制券則効務勢厚句可営因団圧在均基報境墓増夢妻婦容寄富導居属布師常幹序弁張往復徳志応快性恩情態慣承技招授採接提損支政故敵断旧易暴条枝査格桜検構武比永河液混減測準演潔災燃版犯状独率現留略益眼破確示祖禁移程税築精素経統絶綿総編績織罪群義耕職肥能興舌舎術衛製複規解設許証評講謝識護豊財貧責貸貿賀資賛質輸述迷退逆造過適酸鉱銅銭防限険際雑非預領額飼"
    
    static let Kanken5Characters = "並乱乳亡仁供俳値傷優党冊処刻割創劇勤危卵厳収后否吸呼善困垂城域奏奮姿存孝宅宇宗宙宝宣密寸専射将尊就尺届展層己巻幕干幼庁座延律従忘忠憲我批担拝拡捨探推揮操敬映晩暖暮朗机枚染株棒模権樹欲段沿泉洗派済源潮激灰熟片班異疑痛皇盛盟看砂磁私秘穀穴窓筋策簡糖系紅納純絹縦縮署翌聖肺背胸脳腹臓臨至若著蒸蔵蚕衆裁装裏補視覧討訪訳詞誌認誕誠誤論諸警貴賃遺郵郷針鋼閉閣降陛除障難革頂骨"
    
    static let Kanken4Characters = "丈与丘丹乾互井介仰伺依侵俗倒偉傍傾僧儀兼冒凡凶刈到刺剣剤劣勧匹占即却及叫召吐含吹咲唐嘆噴圏坊執堅堤塔壁壊壱奇奥奴妙姓威娘婚寂寝尋尽尾屈峠峰巡巨帽幅幾床弐弾彩影彼征御微徴忙怒怖恋恐恒恥恵悩惑惨慎慢慮憶戒戯扇払扱抗抜抱抵押拍拓拠振捕掘描握援搬摘撃攻敏敷斜旨旬是普暇暦曇更替朱朽杯枯柄柔桃欄歓歳殖殿汗汚沈沖沢沼況泊浜浮浸涙淡添渡溶滴漫澄濁濃為烈煙煮燥爆狂狩狭猛獣獲玄珍環甘畳疲療皆盆盗監盤盾眠瞬矛砲祈秀称稲稿突端箇範粒紋紫紹絡継維網緯縁繁繰罰翼耐肩肪胴脂脚脱腐腕腰膚致舗舞舟般芋芝茂荒菓蓄薄薪被襲触訴詰詳誇誉謡豪販賦贈越趣距跡跳踊踏躍軒較載輝輩込迎迫逃透途遅違遣避郎釈鈍鉛鋭鎖鑑闘陣陰隠隣隷雄雅雌離雷需震霧露響項頼飾香駆騒驚髪鬼鮮麗黙鼓齢"
    
    static let Kanken3Characters = "乏乙了企伏伐伴伸佳侍促倣倹偶催債克免冗冠凍凝刑削励勘募匠匿卑卓卸厘又双吉吏哀哲啓喚喫嘱坑埋塊塗墜墨墳墾壇奉契奪如妨姫娯婆婿嫁嬢孔孤宴審寿封尿岐岳峡崩巧帆帝幻幽廉廊弧彫徐忌怠怪恨悔悟悦惜愚慈慌慕慨慰憂憎憩房抑択抽拘掃掌排掛控措掲揚換揺携搾摂撮擁擦敢斗斤斥施既昇晶暫架某桑棄棋楼概欧欺殊殴没泌浪湾湿滅滑滝滞漂漏潜潤濫瀬炉炊炎焦牲犠猟獄甲畔畜疾痘癖硬碑礎祉稚穂穏穫窒符篤簿籍粋粗粘糧紛紺絞綱緊締緩縛縫繕翻聴肝胆胎胞脅膜膨芳苗菊華葬藩虐虚蛮衝衰袋裂裸覆訂託詠該誘請諮諾謀譲豚貫賊賢赦赴超軌軸辛辱逮遂遇遭遵邦邪郊郭酔酵鋳錠錬錯鍛鎮鐘閲阻陪陳陵陶隆随隔隻雇零霊顧飽餓駐騎髄魂魅魔鯨鶏"
    
    static let KankenPre2Characters = "且丙亜享亭仙伯但佐併侮侯俊俸倫偏偵偽傑傘僕僚儒償充准凸凹刃剖剛剰劾勅勲升厄叔叙吟呈呉唆唇唯喝喪嗣嚇囚坪垣培堀堕堪塀塁塑塚塾壌壮奔奨妃妄妊妥姻娠媒嫌嫡宜宰宵寛寡寧寮尉尚尼履屯岬崇崎帥幣庶庸廃廷弊弔弦彰循徹忍恭悠患悼惰愁愉慶憤憾懇懐懲懸戻扉扶抄把披抹拐拒拙括拷挑挟挿捜据搭摩撤撲擬斉斎旋昆暁曹朕朴杉析枠枢柳栓核栽桟棚棟棺槽款殉殻汁江沸泡泥泰洞津洪浄浦涯涼淑渇渉渋渓渦溝滋漆漠漬漸潟濯煩爵猫献猶猿珠琴璽瓶甚畝疎疫症痢痴癒盲眺睡督矯砕硝硫碁磨礁祥禅禍租秩稼窃窮窯竜筒粛粧糾紡索累紳緒縄繊繭缶罷羅翁耗肌肖肢肯臭舶艇艦茎荘菌薦薫藻虜虞蚊蛇蛍融衡衷裕褐褒襟覇訟診詐詔誓諭謁謄謙謹譜貞貢賄賓賜賠購践軟轄迅迭逐逓逝逸遍遮遷還邸酌酢酪酬酷醜醸釣鈴鉢銃銘閑閥附陥隅雰霜靴韻頑頒頻顕飢駄騰麻"
    
    static let Kanken2Characters = "串丼乞亀伎侶俺傲僅冥冶凄刹剥勃勾匂叱呂呪咽哺唄唾喉喩嗅嘲埼堆塞填奈妖妬媛嫉宛尻岡崖嵐巾弄弥彙怨恣惧慄憧憬戚戴拉拭拳拶挨挫捉捗捻摯斑斬旦旺昧曖曽枕柵柿栃桁梗梨椅椎楷毀氾汎汰沃沙淫湧溺潰煎熊爪爽牙狙玩瑠璃璧瓦畏畿痕痩瘍眉睦瞭瞳稽窟箋箸籠綻緻罵羞羨肘股脇脊腎腫腺膝膳臆臼舷艶芯苛茨萎葛蓋蔑蔽藍藤虎虹蜂蜜袖裾訃詣詮誰諦諧謎貌貪貼賂賭踪蹴辣遜遡那酎醒采釜錦錮鍋鍵鎌闇阜阪隙韓頃須頓頬顎餅餌駒骸鬱鶴鹿麓麺"
    
    static let KankenPre1Characters = "丑丞乃之乍乎也云亘亙些亥亦亨亮什仇仔伊伍伶伽佃佑佼侃侠俄俣倖倦倭倶偲傭僑僻儘儲允兇兔兜其冴凋凌凧凪凰凱函剃劃劉劫勿匙匝匡匪卜卦卯卿厭叉叛叡叢叩只叶吃吊吋吠吻吾呆呑咳哉哨哩唖啄喋喧喬喰嘉嘗嘘嘩噂噌噛噸噺嚢圃圭坐坤坦垢埜埠埴堰堵堺塘塙塵壕壬壺夙夷奄套妓妾姐姑姥姦姪姶娃娩娼婁嬉嬬嬰孜孟宋宍宏宕宥寅寓寵尖尤尭屍屑屡岨岱峨峯峻嵩嵯嶋嶺巌巳巴巷巽帖幌幡庄庇庖庚庵廏廓廚廟廠廻廿弗弘弛弼彊彦彪彬徽忽怜怯恕恢恰悉悌悶惇惚惟惣惹愈慧慾憐戊戎或戟托扮按挺挽捌捧捲捷捺掠掩掬掴掻揃揖摸摺撒撚撞撫播撰擢擾攪敦斌斐斡斧斯於旭昂昌昏晃晋晒晦智暢曙曝曳朋朔李杏杓杖杜杢杭杵杷枇柁柊柏柑柘柚柴柾栂栖栗栴桂桐桓桔桝桶梁梓梢梧梯梱梶棉棲椀椋椙椛椴椿楊楓楚楠楢楯楳榊榎榛槌槍槙槻樋樗樟樫樵樺樽橘橡橢橿檀檎檜檮櫓櫛欣欽歎此歪殆毅毘汀汐汝汲沌沓沫洛洩洲浩浬涌涜淀淋淘淳淵渚渠渥湊湘湛溌溜溢溯漉漑漕漣澗澱濠濡濤瀕瀞瀦瀧灌灘灸灼烏烹焔焚煉煤煽燈燐燕燦燭爺爾牌牒牝牟牡牢牽犀狐狗狛狸狼狽猪猷獅玖玲珂珊珪琉琢琳琵琶瑚瑛瑞瑳瓜瓢甑甜甥甫畠畢畦畷疋疏疹痔癌皐盃盈瞥矧矩砥砦砧硯硲碇碍碓碧碩磐磯礦礪祁祇祐祷禄禎禦禰禽禾禿秤秦稀稔稗稜穆穎穣穿窄窪窺竈竣竺竿笈笠笥笹筈筏筑箔箕箪箭篇篠篦簸簾籾粁粂粍粕粟粥糊糎糞糟糠紐紗紘紬絃絢綜綬綴綾緋緬縞繋繍纂纏罫翠翫翰耀而耶耽聡聯聾肇肋肱肴胡胤脆腔腿膏膿臥舘舛舜舵艮芙芥芭芹苅苑苒苓苔苧苫茄茅茜茸荊荏荻莞莫莱菅菖菟菩菰菱萄萌萩萱葎葡董葦葱葵葺蒋蒐蒔蒙蒜蒲蒼蓉蓑蓬蓮蔀蔓蔚蔦蔭蕃蕉蕊蕎蕗蕨蕩蕪薗薙薩薯藁藪藷蘇蘭虻蚤蛋蛙蛛蛤蛭蛸蛾蜘蝉蝋蝕蝦蝶螺蟹蟻蠅蠣衿袈袴袷裟裡裳襖覗訊訣註詑詫誹誼諏諒諜諫諺謂謬讚豎豹貰賑賤贋赫趨跨蹄蹟躯輔輯輿轍轟轡辰辻辿迂迄迦迺逗這逢逼遁遥遼邇邑郁鄭酉酋醇醍醐醗醤釘釦釧鈷鉤鉦鉾銚鋒鋤鋪鋲鋸錆錐錨錫鍍鍔鍬鍾鎔鎗鎚鎧鏑鐙鐸鑓閃閏閤阿陀隈隼雀雁雛雫霞靖靭鞄鞍鞘鞠鞭韃韭頁頗頸顛飴餐餠饗馨馳馴駁駈駕駿騨髭魁魯鮎鮒鮪鮫鮭鯉鯖鯛鰍鰐鰭鰯鰹鰺鰻鱈鱒鱗鳩鳳鳶鴇鴎鴛鴦鴨鴫鴻鵜鵠鵡鵬鶯鷲鷹鷺鸚鹸麒麟麹麿黍黛鼎鼠龍龝"
    
    static let Kanken1Characters = "丐丕丗个丱丶丿乂乕乖乘乢亂亅亊于亞亟亠亢亰亳亶仂仄仆仍从仗仞仟仭价伉伜估佇佗佚佛佝佞佩佯佰佶佻來侈侏侑侖侘侫侭俎俐俑俔俘俚俛俟俤俥俯俶俾倅倆倏們倔倚倡倥倨倩倪倬偃假偈偐偕偖做偬偸傀傅傚傳傴僂僉僊僖僞僣僥僭僮僵價儁儂儉儔儕儖儚儡儷儺儻儼儿兀兌兎兒兢兩兪兮冀冂冉册冏冐冑冓冕冖冢冤冦冨冩冪冫冰冱冲决况冽凅凉凖凛凜几凩凭凵凾刄刋刎刔刧刪刮刳剄剋剌剏剔剞剩剪剱剳剴剽剿劈劍劑劒劔劬劭劵劼勁勍勒勗勞勠勣勦勳勵勸勹匆匈匍匏匐匕匚匣匯匱匳匸區卅卆卉卍卞卩卮卷卻厂厖厠厥厦厨厩厮厰厶參叟叨叭叮叺吁吝吩听吭吮吶吼吽呀呎呟呰呱呵呶呷呻咀咄咆咋咎咏咐咒咢咤咥咨咫咬咯咸咼咾哂哄哇哈哘哢哥哦哭哮哽唏唔售唳唸唹啀啅啌啖啗啜啝啣啻啼啾喀喃喇喊喘喙喞喟喨單嗄嗇嗔嗚嗜嗟嗤嗷嗹嗽嗾嘔嘖嘛嘯嘴嘶嘸噎噐噤噪噫噬嚀嚆嚊嚏嚔嚠嚥嚮嚴嚶嚼囀囁囂囃囈囎囑囓囗囘囮囹囿圀圄圈圉國圍圓圖團圜圦圷圸圻址坎坏坡坩坿垈垉垓垠垤垪垰垳埀埃埆埒埓埔埖埣堊堋堙堝堡堯堽塋塒塢塰塲塹墅墟墫墮墸墹墺墻壅壑壓壗壘壙壜壞壟壤壥壯壷壹壻壼壽夂夊夐夘夛夥夬夭夲夸夾奎奐奕奘奚奠奢奧奩奬奸妁妍妛妝妣妲姆姙姚姜姨娉娑娚娜娟娥娵娶婀婉婢婪婬媚媼媽媾嫂嫋嫐嫖嫗嫣嫦嫩嫺嫻嬋嬌嬖嬪嬲嬶嬾孀孃孅孑孕孚孛孥孩孰孱孳孵學孺宀它宦宸寃寇寉寐寔寞寢寤寥實寨寫寰寳寶尅將專對尓尠尢尨尸尹屁屆屎屏屐屓屠屬屮屶屹岌岑岔岫岶岷岻岼岾峅峇峙峩峪峭峺峽崋崑崔崕崗崘崙崚崛崟崢嵋嵌嵎嵒嵜嵬嵳嵶嶂嶄嶇嶌嶐嶝嶢嶬嶮嶷嶼嶽巉巍巒巓巖巛巫已巵帋帑帙帚帛帶帷幀幃幄幇幎幔幗幟幢幤幵并幺广庠廁廂廈廐廖廛廝廡廢廣廨廩廬廰廱廳廴廸廼廾弃弉弋弌弍弑弖弩弭弯弸彁彈彌彎彑彖彗彜彝彡彭彳彷彿徂徃徇很徊徑徘徙從徠徨徭徼忖忝忤忰忱忸忻忿怎怏怐怕怙怛怡怦怩怫怱怺恁恂恃恆恊恍恙恚恟恠恤恪恫恬恷悁悃悄悋悍悒悖悗悚悛悧悳悴悵悸悽惆惓惘惠惡惱惴惶惷惺惻愀愃愆愍愎愕愡愧愨愬愴愼愽愾愿慂慇慊慍慓慘慙慚慝慟慥慫慯慱慳慴慵慷憇憊憑憔憖憙憚憫憮憺懃懆懈應懊懋懌懍懣懦懴懶懷懺懼懽懾懿戀戈戉戌戍戔戛戝戞戡截戮戰戲戳扁扈扎扛扞扠扣扨扼找抂抃抉抒抓抔抖抛抬抻拂拆拇拈拊拌拏拑拔拗拜拮拯拱拵拿挂挈挌挧挾捍捏捐捩捫捶掀掉掎掏掖掟掣掫掵掾揀揄揆揉插揣揩揶搆搏搓搖搗搜搦搨搴搶摎摧摶撈撓撕撥撩撹撻撼擂擅擇擒擔擘據擠擡擣擧擯擱擲擴擶擺擽攀攅攘攜攝攣攤攫攬攴攵收攷攸效敍敕敖敘敝敞敲數斂斃斈斛斟斫斷旁旃旄旆旌旒旙旛无旡旱旻昃昊昜昴昵昶昿晁晄晉晏晝晞晟晢晤晧晨晰暃暄暈暉暎暘暝暸暹暼暾曁曄曉曚曠曦曩曰曵曷曼曾會朏朖朞朦朧朮朶朷朸朿杁杆杙杞杠杣杤杪杰杲杳杼枅枉枋枌枡枦枩枳枴枷枸枹柆柎柝柞柢柤柧柩柬柮柯栞栢栩栫栲桀框桍桎桙档桧桴桷桾桿梃梍梏梔梛條梟梠梦梭梳梵梹梺梼棆棊棍棔棕棗棘棠棡棣棧棯棹椁椄椈椌椏椒椚椡椢椣椥椦椨椪椰椶椹椽楔楕楙楜楝楞楡楪楫楮楴楸楹楾榁榑榔榕榜榠榧榮榱榲榴榻榾榿槁槃槇槊槎槐槓槝槞槧槨槫槭槲槹槿樂樅樊樌樒樓樔樛樞樢樣樮樶樸橄橇橈橙橦橲橸檄檍檐檗檠檢檣檪檬檳檸檻櫁櫂櫃櫑櫚櫞櫟櫨櫪櫺櫻欅權欒欖欝欟欷欸欹歃歇歉歐歔歙歛歟歡歸歹歿殀殃殄殍殕殘殞殤殪殫殯殱殲殳殷殼毆毋毓毟毫毬毯毳氈氓气氛氣氤汕汞汢汨汪汳汾沁沂沍沐沒沚沛沮沱沺沽沾泄泅泓泗泙泛泝泪泯泱洌洒洙洟洫洳洵洶洸洽浙浚浣浤浹涅涎涓涕涛涵涸淅淆淇淌淒淕淙淞淤淦淨淪淬淮淹淺渊渕渙渝渟渣渤渫渭渮游渺渾湃湍湎湟湫湮湲湶溂溏溘溟溥溪溲溷溽滂滄滉滌滓滔滕滬滯滲滷滸滾滿漓漱漲漾漿潁潅潘潛潦潭潯潴潸潺潼澀澁澂澆澎澑澡澣澤澪澳澹濂濆濔濕濘濛濟濬濮濱濳濶濺濾瀁瀉瀋瀏瀑瀘瀚瀛瀝瀟瀰瀲瀾灑灣炒炙炬炮炯炳炸烋烙烝烟烱烽焉焙焜煌煕煖煢煥煦煬熄熈熏熔熕熙熨熬熹熾燉燎燒燔燗營燠燧燬燮燵燹燻燼燿爍爐爛爨爬爭爰爲爻爼爿牀牆牋牘牴牾犁犂犇犒犖犢犧犲犹狃狄狆狎狒狠狡狢狷狹猊猖猗猜猝猥猩猯猴猾獎獏獗獨獪獰獵獸獺獻玳玻珀珈珎珞珥珮珱珸琅琥琲琺琿瑁瑕瑙瑜瑟瑣瑤瑩瑪瑯瑰瑶瑾璋璞璢瓊瓏瓔瓠瓣瓧瓩瓮瓰瓱瓲瓷瓸甃甄甅甌甍甎甓甕甞甦甬甸甼畄畆畉畊畋畍畚畛畤畧畩畫畭畴當畸疂疆疇疉疊疔疚疝疣疥疱疳疵疸疼疽痂痃痊痍痒痙痞痣痰痲痳痺痼痾痿瘁瘉瘋瘟瘠瘡瘢瘤瘧瘰瘴瘻癆癇癈癘癜癡癢癧癨癩癪癬癰癲癶癸發皀皃皈皋皎皓皖皙皚皰皴皷皸皹皺盂盍盒盖盜盞盡盥盧盪盻眄眇眈眛眞眤眥眦眩眷眸睇睚睛睥睨睫睹睾睿瞋瞎瞑瞞瞠瞰瞶瞹瞻瞼瞽瞿矇矍矗矚矜矣矮矼砌砒砠砺砿硅硴硼碆碌碎碕碗碚碣碪碯碵碼碾磅磆磊磋磑磔磚磧磬磴磽礇礑礒礙礫礬祀祓祕祗祚祟祠祢祺祿禀禊禝禧禪禮禳禹禺秉秕秡秣秧秬稈稍稘稙稟稠稱稷稻稾穃穉穐穗穡穢穩穰穹穽窈窕窖窗窘窩窰窶窿竃竄竅竇竊竍竏竒竓竕站竚竝竟竡竢竦竪竭竰竸笂笄笆笊笋笏笘笙笞笨笳笵笶筅筌筍筐筝筥筧筬筮筰筱筴筵筺箆箍箏箒箘箙箚箜箝箟箴篁篆篋篌篏篝篥篩篭篳篶篷簀簇簍簑簒簓簔簗簟簣簧簪簫簷簽籀籃籌籏籐籔籖籘籟籤籥籬籵粃粐粡粢粤粨粫粭粮粱粲粳粹粽糀糂糅糒糘糜糢糯糲糴糶糺紂紆紊紕紜紮紲紵紿絅絆絋絎絏絖絛絣絨絮絲絳絽綉綏經綛綟綢綣綫綮綯綰綵綸綺綽緇緕緘緜緝緞緡緤緲縅縉縊縋縒縟縡縢縣縱縲縵縷縹縺縻總繃繆繖繙繚繝繞繦繧繩繪繹繻繼繽繿纃纈纉續纎纐纒纓纔纖纛纜缸缺罅罌罍罎罐网罔罕罘罟罠罧罨罩罸罹羂羃羆羇羈羌羔羚羝羣羮羯羲羶羸羹翅翆翊翔翕翡翦翩翳翹耄耆耋耒耘耙耜耡耨耻耿聆聊聒聘聚聟聢聨聰聲聳聶聹聽聿肄肅肆肓肚肛肬肭胄胖胙胚胛胝胥胯胱胼脉脛脣脩脯脾腆腋腑腓腟腥腦腮腱腴膀膂膃膈膊膓膕膠膣膤膩膰膵膸膺膽膾臀臂臈臉臍臑臘臙臚臟臠臧臺臻臾舁舂舅與舉舊舍舐舒舖舩舫舮舳舸艀艘艙艚艝艟艢艤艨艪艫艱艷艸艾芍芒芟芦芫芬芻苙苜苞苟苡苣苳苴苹苺苻范茆茉茖茗茘茣茫茯茱茲茴茵茹荀荅荐荳荵荼莅莇莉莊莎莓莖莚莟莠莢莨莪莵莽菁菎菘菠菫菲菴菷菻菽萃萇萋萍萓萠萢萪萬萵萸萼葆葢葩葫葭葮葯葷葹蒂蒄蒟蒡蒭蒹蒻蒿蓁蓆蓊蓍蓐蓖蓙蓚蓴蓼蓿蔆蔔蔕蔗蔘蔟蔡蔬蕀蕁蕈蕋蕕蕘蕚蕣蕭蕷蕾薀薇薈薊薐薑薔薛薜薤薨薮薹薺藉藏藐藕藜藝藥藹藺藾蘂蘆蘊蘋蘓蘖蘗蘚蘢蘯蘰蘿虍虔處號虧虱蚋蚌蚓蚣蚩蚪蚫蚯蚰蚶蛄蛆蛉蛎蛔蛞蛟蛩蛬蛯蛹蛻蜀蜃蜆蜈蜉蜊蜍蜑蜒蜚蜥蜩蜴蜷蜻蜿蝌蝎蝓蝗蝙蝟蝠蝣蝨蝪蝮蝴蝸蝿螂螟螢螫螯螳螻螽蟀蟄蟆蟇蟋蟐蟒蟠蟯蟲蟶蟷蟾蠍蠎蠏蠑蠕蠖蠡蠢蠧蠱蠶蠹蠻衂衄衍衒衙衞衢衫衲衵衽衾袁袂袍袒袗袙袞袢袤袮袰袱袵袿裃裄裔裘裙裝裨裲裴裹裼褂褄褊褌褓褝褞褥褪褫褶褸褻襁襃襄襌襍襞襠襤襦襪襭襯襴襷襾覃覈覊覓覘覡覦覩覬覯覲覺覽覿觀觚觜觝觧觴觸訌訐訖訛訝訥訶詁詆詈詒詛詢詬詭詼誂誄誅誑誚誡誣誥誦誨諂諄諌諍諚諛諞諠諡諢諤諱諳諷謇謌謐謔謖謗謚謠謦謨謫謳謾譁證譌譎譏譖譚譛譟譫譬譯譱譴譽讀讃變讌讎讐讒讓讖讙谺谿豁豈豌豐豕豢豫豬豸豺豼貂貅貉貊貍貎貔貘貭貮貲貳貶貽賁賈賍賎賚賣賺賻賽贄贅贇贊贍贏贐贓贔贖赧赭赱赳趁趙趺趾跂跋跌跏跖跚跛跟跣跪跫跼跿踈踉踐踝踞踟踰踴踵蹂蹇蹈蹉蹊蹌蹐蹕蹙蹠蹣蹤蹲蹶蹼躁躄躅躇躊躋躑躓躔躙躡躪躬躰躱躾軅軆軈軋軛軣軫軻軼軾輅輊輌輒輓輕輙輛輜輟輦輳輹輻輾轂轅轆轉轌轎轗轜轢轣轤辜辟辧辨辭辮辯辷迚迢迥迩迪迯迴迸迹逅逋逍逎逑逕逖逞逡逧逵逶逹逾遉遏遐遑遒遖遘遙遞遨遯遲遶遽邀邁邂邃邉邊邏邨邯邱邵郛郢郤鄂鄒鄙鄰鄲酊酖酘酣酥酩酲酳醂醉醋醢醪醫醯醴醵醺釀釁釆釉釋釐釖釛釟釡釵釶釼釿鈎鈑鈔鈕鈞鈩鈬鈿鉅鉈鉉鉋鉐鉗鉚鉞銓銕銖銛銜銷銹鋏鋩鋺錏錙錚錢錣錵錺錻鍄鍖鍜鍠鍮鍼鎬鎭鎰鎹鏃鏈鏐鏖鏗鏘鏝鏤鏥鏨鐃鐇鐐鐓鐔鐚鐡鐫鐵鐶鐺鑁鑄鑒鑚鑛鑞鑠鑢鑪鑰鑵鑷鑼鑽鑾鑿钁閂閇閊閔閖閘閙閠閧閨閭閹閻閼閾闃闊闌闍闔闕闖關闡闢闥阡阨阮阯陂陋陌陏陜陝陞陟陦陬陲陷隋隍隕隗隘隧隨險隰隱隲隴隶隸隹雉雋雍雎雕雖雙雜雹霄霆霈霍霎霏霑霓霖霙霤霪霰霸霹霽霾靂靄靆靈靉靜靠靡靤靦靨靫靱靹靺靼鞁鞅鞆鞋鞏鞐鞜鞣鞦鞨鞫鞳鞴韆韈韋韜韮韲韵韶頌頏頚頡頤頴頷頽顆顋顏顫顯顰顱顳顴颪颯颱颶飃飄飆飜飩飫飭飮餃餉餒餔餘餝餞餡餤餬餮餽餾饂饅饉饋饌饐饑饒饕馗馘馥馭馮馼駑駘駛駝駟駢駭駮駱駲駸駻騁騅騏騙騫騷騾驀驂驃驅驍驕驗驛驟驢驤驥驩驪驫骭骰骼髀髏髑髓體髞髟髢髣髦髫髮髯髱髴髷髻鬆鬘鬚鬟鬢鬣鬥鬧鬨鬩鬪鬮鬯鬲鬻魃魄魍魎魏魑魘魴鮃鮑鮓鮖鮗鮟鮠鮨鮴鮹鯀鯆鯊鯏鯑鯒鯔鯡鯢鯣鯤鯰鯱鯲鯵鰄鰆鰈鰉鰊鰌鰒鰓鰔鰕鰛鰡鰤鰥鰮鰰鰲鰾鱆鱇鱚鱠鱧鱶鱸鳧鳫鳬鳰鴃鴆鴈鴉鴒鴕鴟鴣鴪鴬鴾鴿鵁鵄鵆鵈鵐鵑鵙鵝鵞鵤鵯鵲鵺鶇鶉鶚鶤鶩鶫鶲鶸鶺鶻鷁鷂鷄鷆鷏鷓鷙鷦鷭鷯鷸鷽鸛鸞鹵鹹鹽麁麈麋麌麑麕麝麥麩麪麭麸麼麾黌黎黏黐黔默黜黝點黠黥黨黯黴黶黷黹黻黼黽鼇鼈鼕鼡鼬鼾齊齋齎齏齒齔齟齠齡齣齦齧齪齬齲齶齷龕龜龠"
    
}
