//
//  File.swift
//  
//
//  Created by Morten Bertz on 2020/07/06.
//

import Foundation


public enum JLPTFilter:String, CharacterFiltering, Equatable, Codable, CaseIterable, Identifiable, CustomStringConvertible{
    
    case JLTP5
    case JLPT4
    case JLPT3
    case JLPT2
    case JLPT1
    
    public var disallowedCharacters: Set<String>{
        switch self {
        case .JLTP5:
            return Set(JLPTFilter.JLPT5Characters.map({String($0)}))
        case .JLPT4:
            return JLPTFilter.JLTP5.disallowedCharacters.union(JLPTFilter.JLPT4Characters.map({String($0)}))
        case .JLPT3:
            return JLPTFilter.JLPT4.disallowedCharacters.union(JLPTFilter.JLPT3Characters.map({String($0)}))
        case .JLPT2:
            return JLPTFilter.JLPT3.disallowedCharacters.union(JLPTFilter.JLPT2Characters.map({String($0)}))
        case .JLPT1:
            return JLPTFilter.JLPT2.disallowedCharacters.union(JLPTFilter.JLPT1Characters.map({String($0)}))
        
        }
    }
    
    
    public var localizedName: String{
        let tableName = "Localizable"
        switch self {
        case .JLPT1:
            return Bundle.module.localizedString(forKey: "JLPT1", value: "JLPT Level N1", table: tableName)
        case .JLPT2:
            return Bundle.module.localizedString(forKey: "JLPT2", value: "JLPT Level N2", table: tableName)
        case .JLPT3:
            return Bundle.module.localizedString(forKey: "JLPT3", value: "JLPT Level N3", table: tableName)
        case .JLPT4:
            return Bundle.module.localizedString(forKey: "JLPT4", value: "JLPT Level N4", table: tableName)
        case .JLTP5:
            return Bundle.module.localizedString(forKey: "JLPT5", value: "JLPT Level N5", table: tableName)
        }
    }
    
    public init?(data: Data) {
        if let f=try? JSONDecoder().decode(JLPTFilter.self, from: data){
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

extension JLPTFilter{
    static let JLPT5Characters = "安一飲右雨駅円火花下何会外学間気九休魚金空月見言古五後午語校口行高国今左三山四子耳時七車社手週十出書女小少上食新人水生西川千先前足多大男中長天店電土東道読南ニ日入年買白八半百父分聞母北木本毎万名目友来立六話"
    
    static let JLPT4Characters = "悪暗医意以引院員運英映遠屋音歌夏家画海回開界楽館漢寒顔帰起究急牛去強教京業近銀区計兄軽犬研県建験元工広考光好合黒菜作産紙思姉止市仕死使始試私字自事持室質写者借弱首主秋集習終住重春所暑場乗色森心親真進図青正声世赤夕切説洗早走送族村体太待貸台代題短知地池茶着昼注町鳥朝通弟低転田都度答冬頭同動堂働特肉売発飯病品不風服物文別勉便歩方妹味民明門問夜野薬有曜用洋理旅料力林"
    
    static let JLPT3Characters = "政議民連対部合市内相定回選米実関決全表戦経最現調化当約首法性要制治務成期取都和機平加受続進数記初指権支産点報済活原共得解交資予向際勝面告反判認参利組信在件側任引求所次昨論官増係感情投示変打直両式確果容必演歳争談能位置流格疑過局放常状球職与供役構割費付由説難優夫収断石違消神番規術備宅害配警育席訪乗残想声念助労例然限追商葉伝働形景落好退頭負渡失差末守若種美命福望非観察段横深申様財港識呼達良候程満敗値突光路科積他処太客否師登易速存飛殺号単座破除完降責捕危給苦迎園具辞因馬愛富彼未舞亡冷適婦寄込顔類余王返妻背熱宿薬険頼覚船途許抜便留罪努精散静婚喜浮絶幸押倒等老曲払庭徒勤遅居雑招困欠更刻賛抱犯恐息遠戻願絵越欲痛笑互束似列探逃遊迷夢君閉緒折草暮酒悲晴掛到寝暗盗吸陽御歯忘雪吹娘誤洗慣礼窓昔貧怒泳祖杯疲皆鳴腹煙眠怖耳頂箱晩寒髪忙才靴恥偶偉猫幾"
    
    static let JLPT2Characters = "党協総区領県設改府査委軍団各島革村勢減再税営比防補境導副算輸述線農州武象域額欧担準賞辺造被技低復移個門課脳極含蔵量型況針専谷史階管兵接細効丸湾録省旧橋岸周材戸央券編捜竹超並療採森競介根販歴将幅般貿講林装諸劇河航鉄児禁印逆換久短油暴輪占植清倍均億圧芸署伸停爆陸玉波帯延羽固則乱普測豊厚齢囲卒略承順岩練軽了庁城患層版令角絡損募裏仏績築貨混昇池血温季星永著誌庫刊像香坂底布寺宇巨震希触依籍汚枚複郵仲栄札板骨傾届巻燃跡包駐弱紹雇替預焼簡章臓律贈照薄群秒奥詰双刺純翌快片敬悩泉皮漁荒貯硬埋柱祭袋筆訓浴童宝封胸砂塩賢腕兆床毛緑尊祝柔殿濃液衣肩零幼荷泊黄甘臣浅掃雲掘捨軟沈凍乳恋紅郊腰炭踊冊勇械菜珍卵湖喫干虫刷湯溶鉱涙匹孫鋭枝塗軒毒叫拝氷乾棒祈拾粉糸綿汗銅湿瓶咲召缶隻脂蒸肌耕鈍泥隅灯辛磨麦姓筒鼻粒詞胃畳机膚濯塔沸灰菓帽枯涼舟貝符憎皿肯燥畜挟曇滴伺"
    
    static let JLPT1Characters = "氏統保第結派案策基価提挙応企検藤沢裁証援施井護展態鮮視条幹独宮率衛張監環審義訴株姿閣衆評影松撃佐核整融製票渉響推請器士討攻崎督授催及憲離激摘系批郎健盟従修隊織拡故振弁就異献厳維浜遺塁邦素遣抗模雄益緊標宣昭廃伊江僚吉盛皇臨踏壊債興源儀創障継筋闘葬避司康善逮迫惑崩紀聴脱級博締救執房撤削密措志載陣我為抑幕染奈傷択秀徴弾償功拠秘拒刑塚致繰尾描鈴盤項喪伴養懸街契掲躍棄邸縮還属慮枠恵露沖緩節需射購揮充貢鹿却端賃獲郡併徹貴衝焦奪災浦析譲称納樹挑誘紛至宗促慎控智握宙俊銭渋銃操携診託撮誕侵括謝駆透津壁稲仮裂敏是排裕堅訳芝綱典賀扱顧弘看訟戒祉誉歓奏勧騒閥甲縄郷揺免既薦隣華範隠徳哲杉釈己妥威豪熊滞微隆症暫忠倉彦肝喚沿妙唱阿索誠襲懇俳柄驚麻李浩剤瀬趣陥斎貫仙慰序旬兼聖旨即柳舎偽較覇詳抵脅茂犠旗距雅飾網竜詩繁翼潟敵魅嫌斉敷擁圏酸罰滅礎腐脚潮梅尽僕桜滑孤"
}
