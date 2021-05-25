//
//  File.swift
//  
//
//  Created by Morten Bertz on 2020/07/06.
//

import Foundation

public enum SchoolYearFilter:String, CharacterFiltering,Codable,CaseIterable,Hashable, Identifiable, CustomStringConvertible{
    
    case elementary1
    case elementary2
    case elementary3
    case elementary4
    case elementary5
    case elementary6
    case middle1
    case middle2
    case middle3
    case highSchool
    
    
    
    public var disallowedCharacters: Set<String>{
        switch self {
        case .elementary1:
            return Set(SchoolYearFilter.elementary1Characters.map({String($0)}))
        case .elementary2:
            return SchoolYearFilter.elementary1.disallowedCharacters.union(SchoolYearFilter.elementary2Characters.map({String($0)}))
        case .elementary3:
            return SchoolYearFilter.elementary2.disallowedCharacters.union(SchoolYearFilter.elementary3Characters.map({String($0)}))
        case .elementary4:
            return SchoolYearFilter.elementary3.disallowedCharacters.union(SchoolYearFilter.elementary4Characters.map({String($0)}))
        case .elementary5:
            return SchoolYearFilter.elementary4.disallowedCharacters.union(SchoolYearFilter.elementary5Characters.map({String($0)}))
        case .elementary6:
            return SchoolYearFilter.elementary5.disallowedCharacters.union(SchoolYearFilter.elementary6Characters.map({String($0)}))
        case .middle1:
            return SchoolYearFilter.elementary6.disallowedCharacters.union(SchoolYearFilter.middle1Characters.map({String($0)}))
        case .middle2:
            return SchoolYearFilter.middle1.disallowedCharacters.union(SchoolYearFilter.middle2Characters.map({String($0)}))
        case .middle3:
            return SchoolYearFilter.middle2.disallowedCharacters.union(SchoolYearFilter.middle3Characters.map({String($0)}))
        case .highSchool:
            return SchoolYearFilter.middle3.disallowedCharacters.union(SchoolYearFilter.highSchoolCharacters.map({String($0)}))
        
        }
    }
       
    public var localizedName: String{
        return Bundle.module.localizedString(forKey: self.rawValue, value: self.rawValue, table: "Localizable")
    }
    
    public init?(data: Data) {
        if let f=try? JSONDecoder().decode(SchoolYearFilter.self, from: data){
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



extension SchoolYearFilter{
    static let elementary1Characters = "一二三四五六七八九十百千上下左右中大小月日年早木林山川土空田天生花草虫犬人名女男子目耳口手足見音力気円入出立休先夕本文字学校村町森正水火玉王石竹糸貝車金雨赤青白"
    
    static let elementary2Characters = "数多少万半形太細広長点丸交光角計直線矢弱強高同親母父姉兄弟妹自友体毛頭顔首心時曜朝昼夜分週春夏秋冬今新古間方北南東西遠近前後内外場地国園谷野原里市京風雪雲池海岩星室戸家寺通門道話言答声聞語読書記紙画絵図工教晴思考知才理算作元食肉馬牛魚鳥羽鳴麦米茶色黄黒来行帰歩走止活店買売午汽弓回会組船明社切電毎合当台楽公引科歌刀番用何"
    
    static let elementary3Characters = "丁世両主乗予事仕他代住使係倍全具写列助勉動勝化区医去反取受号向君味命和品員商問坂央始委守安定実客宮宿寒対局屋岸島州帳平幸度庫庭式役待急息悪悲想意感所打投拾持指放整旅族昔昭暑暗曲有服期板柱根植業様横橋次歯死氷決油波注泳洋流消深温港湖湯漢炭物球由申界畑病発登皮皿相県真着短研礼神祭福秒究章童笛第筆等箱級終緑練羊美習者育苦荷落葉薬血表詩調談豆負起路身転軽農返追送速進遊運部都配酒重鉄銀開院陽階集面題飲館駅鼻"
    
     static let elementary4Characters = "不争付令以仲伝位低例便信倉候借停健側働億兆児共兵典冷初別利刷副功加努労勇包卒協単博印参史司各告周唱喜器囲固型堂塩士変夫失好季孫完官害察巣差希席帯底府康建径徒得必念愛成戦折挙改救敗散料旗昨景最望未末札材束松果栄案梅械極標機欠歴残殺毒氏民求治法泣浅浴清満漁灯無然焼照熱牧特産的省祝票種積競笑管節粉紀約結給続置老胃脈腸臣航良芸芽英菜街衣要覚観訓試説課議象貨貯費賞軍輪辞辺連達選郡量録鏡関陸隊静順願類飛飯養験"
    
     static let elementary5Characters = "久仏仮件任似余価保修俵個備像再刊判制券則効務勢厚句可営因団圧在均基報境墓増夢妻婦容寄富導居属布師常幹序弁張往復徳志応快性恩情態慣承技招授採接提損支政故敵断旧易暴条枝査格桜検構武比永河液混減測準演潔災燃版犯状独率現留略益眼破確示祖禁移程税築精素経統絶綿総編績織罪群義耕職肥能興舌舎術衛製複規解設許証評講謝識護豊財貧責貸貿賀資賛質輸述迷退逆造過適酸鉱銅銭防限険際雑非預領額飼"
    
     static let elementary6Characters = "並乱乳亡仁供俳値傷優党冊処刻割創劇勤危卵厳収后否吸呼善困垂城域奏奮姿存孝宅宇宗宙宝宣密寸専射将尊就尺届展層己巻幕干幼庁座延律従忘忠憲我批担拝拡捨探推揮操敬映晩暖暮朗机枚染株棒模権樹欲段沿泉洗派済源潮激灰熟片班異疑痛皇盛盟看砂磁私秘穀穴窓筋策簡糖系紅納純絹縦縮署翌聖肺背胸脳腹臓臨至若著蒸蔵蚕衆裁装裏補視覧討訪訳詞誌認誕誠誤論諸警貴賃遺郵郷針鋼閉閣降陛除障難革頂骨並乱乳亡仁供俳値傷優党冊処刻割創劇勤危卵"
    
    static let middle1Characters = "歳爆需稿暇奥寝扱震鋭盾軒荒惑触刈狩添汗驚耐継避奴汚狭矛踊芋繰杯桃介勧豪依踏捕搬弾憶怒療暦鬼込珍殖香惨畳胴怖煙圏維婚霧芝丈及網齢眠抗響与幾侵濁脂抜環壁項濃迎尋旨到麗露陣峠渡滴傍丘旬妙煮較執床壊仰刺咲載曇沈猛陰突浜罰峰抱彩摘鉛堅脚叫殿抵召駆沖影迫致押俗兼秀輝浮紋枯販為恋丹攻訴飾彼掘沢恐噴恒浸征脱輩坊郎疲欄拍壱皆巡尽烈越尾傾剣緯堤剤拓逃冒襲頼匹砲巨柄敏更漫吐屈恥姓隠撃透舗黙被沼紫拠箇謡隣替途縁戒況舞是柔舟闘趣腐御涙恵泊紹称腕伺慎釈般隷獣含菓茂微倒僧占描鮮徴賦詰敷雄戯躍雅塔薄詳獲吹甘鑑騒慢唐乾雌腰威髪盆握即却劣慮儀蓄遅肩玄朱肪絡誇鼓祈扇誉粒燥端歓互鎖範盗井離悩贈朽援瞬忙凡奇娘距繁違斜普狂寂払跡薪監嘆弐盤帽偉振稲澄淡遣幅膚雷溶凶鈍跳翼"
    
    static let middle2Characters = "遭辛篤軌穂畔擦膨弧滅遵侍豚岳施奪勘霊畜胞阻啓墜鋳埋募穏審憩婆滑酔刑符殊辱惜嘱墨嬢請偶滝滞如克免墳暫桑魂抑衝寿炊訂又炉封綱魅藩携双炎幻怠穫既幽搾軸墾糧摂癖択脅酵怪峡壇邦魔衰錠陪邪託芳促殴諮赦緊漂陳猟掃妨陵錬陶彫錯婿哀削孔企掌赴諾浪葬匠抽漏昇謀窒愚喚排催袋閲締飽駐貫隆没濫簿伏郊蛮伐債掛孤架超苗緩随鐘喫紛隔坑尿吉籍巧獄牲控措拘疾冗餓徐乏吏匿恨礎掲聴冠鍛某賊乙廉髄廊覆崩哲楼郭敢伴慈菊卑卓紺泌詠慌概伸欧痘帆姫裂隻塊嫁慕賢虐湾逮縛湿顧騎該欺棄雇犠塗虚瀬揚換潜倣撮肝棋悔帝慨縫凍硬了潤房遂華粋絞卸慰忌悟遇稚宴祉擁悦凝甲粗倹粘斗励岐奉憂揺誘佳晶契斤裸斥焦譲胆憎零鎮碑厘膜鯨繕娯鶏翻胎"
    
    static let middle3Characters = "践遮岬挿寛弦洞奨刃褐寡缶遷擬褒扶憤津酌畝核滋寧荘洪栽繭幣殉寮軟還旋附江耗禅抄充渇霜偵渉搭捜把渋禍妃酢鈴妄勲憾偽仙矯渓韻妊侮融迅惰侯浄衡酪酬槽爵懇癒据尉叔且桟珠煩蛇閑陥懐析叙酷丙傑渦愁蛍藻培壌飢疎頑璽頒諭披傘衷筒尚愉堀妥訟窃俊眺殻枠漆糾枢臭閥緒邸罷貞駄浦砕磨彰抹鉢貢猫昆迭謁献麻襟謄隅喝堕羅懲剖摩疫醜崇猶媒剛診壮懸濯漠崎尼喪拐猿庶拒礁頻庸紡睡謙索堪督拙漬嚇窮窯銃沸賄曹租俸剰靴廃逐詐症逓醸升瓶恭詔累漸轄縄伯秩紳僕吟覇坪括賓逝顕僚塀菌塁銘琴循賜謹拷履肌賠朕痢舶唆但唇塑翁撤硝涯宜屯肖徹茎嫌姻泡柳款甚准逸佐塚嗣泥竜虞裕虜潟撲戻釣艇痴肢硫涼倫挑呈斉廷呉帥泰購宰忍斎悠嫡朴棚患宵慶肯扉譜溝遍棟挟厄淑粛誓騰薦碁垣栓儒弊亜唯薫娠塾劾囚杉繊艦雰粧併弔奔償悼勅偏享蚊祥汁暁亭凸棺凹盲稼"
    
    static let highSchoolCharacters =  "妖謠脹貌萎叱陷痩戚骸晚覽侶璃彈晝劍彌巢芯鎭檢衞乘郞妬腎睦稻稽彙乞戰滯戲萬貪戴薗蜂涉燈頃隙氣瘍巾箸須燒璧鶴喉貼塞穗纖腫攝塡踪惠頓岡惡險賂柵苛薰兒蜜亀髮惧鷄填勃瘦柿氾孃腺辣栃圈國類袖俺收訃葛頬楷汎圓喩頰呂藍團單藏賣齊亞銑瞭從帶賭瞳敍膝藝𠮟獸櫻雜賴瓦藤嗅藥揭勳顎增曆讓汰淚徵曉勺德窟膳勾呪匁鬱匂蹴駈淨曖桁淫爪酎峯榮沃茨爭駒爲冥臆冨裝峽愼顯神祥福爽搖玩慄宛祕諸沙龍搜冶潰都鑄綠臟斑曽侮曾崖僧凄壘勉詣拂勤卑聽澁凉嘆壞器裾牙墨拉層悔詮憎懲敏暑梅闇海蓋醉拔漢煮綻壯斬臼碑社祉拜祈醒祖伎肘祝禍渴穀突與咽錄節壽練籠步繁股署畏者臭虎拭著梗樂嘲視謁謹緖盃賓拳贈條逸寢拶難響錘歷虛實嵐莊怨靜緣梨寬騷禪摯錦禮卷釀盜鹿誰錮樣卽盡憧旦采遜飜舷湧欄憬緻虹遡濕傲畿蔑傳媛將恆專廊麓哺朗廣疊驗旺罵煎釜挨阜鍊挫僅鍋唄佛狀埜虜奈廳應嶋刹阪恣眉餅縣粹毀弄餌僞諦蔽諧嫉狙麺捉縱眞脇埼尻奧羞脊每黃碍昧艶碎奬鍵枕來捗橫那堆剝羨溫椅黑價擊剥懷熊弥瑠椎剩唾默狹溺轉瀧瀨謎串鎌痕儉嚴韓丼捻箋"
}
