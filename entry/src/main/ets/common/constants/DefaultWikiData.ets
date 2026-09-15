import { SpeciesModel } from '../models/SpeciesModel';
import { PlantModel } from '../models/PlantModel';
import { CareLogModel } from '../models/CareLogModel';
import { DiaryModel } from '../models/DiaryModel';
import { SPECIES_FOLIAGE } from './species/SpeciesData_Foliage';
import { SPECIES_FLOWER } from './species/SpeciesData_Flower';
import { SPECIES_SUCCULENT } from './species/SpeciesData_Succulent';
import { SPECIES_ORCHID } from './species/SpeciesData_Orchid';
import { SPECIES_BULB } from './species/SpeciesData_Bulb';
import { SPECIES_HERB } from './species/SpeciesData_Herb';

/**
 * 每日精选花语与养护箴言集
 */
export interface DailyQuote {
  quote: string;
  flower: string;
  source: string;
}

export const DAILY_QUOTES: DailyQuote[] = [
  { quote: '以琉璃为器，以花语为引。一枝一叶总关情。', flower: '绿萝', source: '琉璃花语' },
  { quote: '宁静致远，坚韧长青，在岁月里沉淀最温柔的守护。', flower: '虎皮兰', source: '植物物语' },
  { quote: '即使身处幽微角落，亦有破土舒展的盎然生气。', flower: '龟背竹', source: '草木心' },
  { quote: '静待花开，不仅是一种修行，更是与时光最美妙的约定。', flower: '君子兰', source: '花间拾忆' },
  { quote: '空谷幽兰，香气自生；花若盛开，清风自来。', flower: '蝴蝶兰', source: '兰蕙清韵' },
  { quote: '带刺的茎蔓上，孕育着对烈日与生活最炽烈的热爱。', flower: '月季', source: '玫瑰之约' },
  { quote: '小小的饱满叶片，藏着一整个夏天的蓄势与丰盈。', flower: '多肉玉露', source: '多肉记' },
  { quote: '历经冬日深沉的休眠，必在初春绽放最明媚的笑靥。', flower: '仙客来', source: '四时花令' },
  { quote: '不攀不附，自垂绿瀑；净化微尘，抚慰烦心。', flower: '吊兰', source: '绿意生活' },
  { quote: '文竹含风雅，清简照素心。愿你在忙碌之中留一方闲境。', flower: '文竹', source: '书斋清供' },
  { quote: '一勺清水润泥土，半缕暖阳度初晨。生活无需繁复。', flower: '茉莉花', source: '晨光花事' },
  { quote: '球茎深埋于泥土之下，那是生命的蓄力与期待。', flower: '朱顶红', source: '球根手记' },
  { quote: '叶色斑斓随季改，冷冽秋风染红霜。生命当如斯绚烂。', flower: '长寿花', source: '庭院小记' },
  { quote: '水培清莹见白根，岁寒不改绿衣裳。', flower: '富贵竹', source: '水木清华' },
  { quote: '琴叶宽舒遮烦虑，绿伞轻撑护幽居。', flower: '琴叶榕', source: '现代居植' },
  { quote: '清香淡雅袭人醉，洁白如雪映晴窗。', flower: '栀子花', source: '初夏花信' },
  { quote: '薄荷清凉沁肺腑，一叶轻掐散忧思。', flower: '薄荷', source: '香草物语' },
  { quote: '生石开花石破天惊，大漠顽石亦有柔情。', flower: '生石花', source: '奇趣多肉' },
  { quote: '万簇相拥成粉黛，无尽夏中品清欢。', flower: '绣球花', source: '夏日花序' },
  { quote: '聚八方祥和之气，守四季如常之安。', flower: '发财树', source: '绿意雅轩' }
];

/**
 * 预置精选花种百科数据库（包含6大分类共120种植物）
 */
export const DEFAULT_SPECIES_LIST: SpeciesModel[] = [
  ...SPECIES_FOLIAGE,
  ...SPECIES_FLOWER,
  ...SPECIES_SUCCULENT,
  ...SPECIES_ORCHID,
  ...SPECIES_BULB,
  ...SPECIES_HERB
];

export const DEFAULT_INITIAL_PLANTS: PlantModel[] = [
  {
    id: 'plt_sample_1',
    speciesId: 'sp_lvluo',
    name: '绿萝',
    nickname: '书房清风小绿',
    location: '书房窗台',
    potSize: '中盆(18cm)',
    icon: '🌿',
    acquireDate: '2026-03-01',
    waterInterval: 5,
    fertilizeInterval: 20,
    lastWaterDate: '2026-09-12',
    lastFertilizeDate: '2026-08-25',
    healthStatus: 'thriving',
    notes: '水培转土培，生机盎然，叶片非常翠绿',
    isFavorite: true
  },
  {
    id: 'plt_sample_2',
    speciesId: 'sp_hudielan',
    name: '蝴蝶兰',
    nickname: '阳台紫蝶',
    location: '南阳台散光区',
    potSize: '透明水苔盆(12cm)',
    icon: '🌸',
    acquireDate: '2026-04-15',
    waterInterval: 7,
    fertilizeInterval: 15,
    lastWaterDate: '2026-09-08',
    lastFertilizeDate: '2026-08-30',
    healthStatus: 'healthy',
    notes: '正处于花后养根期，新根长势喜人',
    isFavorite: true
  },
  {
    id: 'plt_sample_3',
    speciesId: 'sp_yulu',
    name: '玉露',
    nickname: '案头冰灯',
    location: '书桌柔光区',
    potSize: '紫砂微型盆(8cm)',
    icon: '💎',
    acquireDate: '2026-05-20',
    waterInterval: 10,
    fertilizeInterval: 45,
    lastWaterDate: '2026-09-05',
    lastFertilizeDate: '2026-08-01',
    healthStatus: 'thriving',
    notes: '颗粒土闷养中，窗面晶莹通透',
    isFavorite: false
  }
];

/**
 * 默认初始日记示例
 */
export const DEFAULT_INITIAL_DIARIES: DiaryModel[] = [
  {
    id: 'dry_sample_1',
    plantId: 'plt_sample_1',
    plantName: '书房清风小绿',
    title: '剪下三根新藤，水培生根',
    content: '小绿的藤蔓已经垂过书桌边沿了，剪了三节带气生根的茎插在水培琉璃瓶里，第三天就冒出了白嫩嫩的新根须，生命力太惊人了！',
    date: '2026-09-10',
    time: '14:30',
    tag: 'sprout',
    tagName: '萌发新芽',
    mood: '🌱'
  },
  {
    id: 'dry_sample_2',
    plantId: 'plt_sample_2',
    plantName: '阳台紫蝶',
    title: '浸盆补水与透气检查',
    content: '今天水苔彻底干白了，根系呈现淡银灰色。用温室水浸盆10分钟，根系瞬间转为鲜活的翠绿色。修剪掉了一支残余的花梗。',
    date: '2026-09-08',
    time: '09:15',
    tag: 'observe',
    tagName: '日常观察',
    mood: '💧'
  }
];

/**
 * 默认初始打卡记录
 */
export const DEFAULT_INITIAL_CARE_LOGS: CareLogModel[] = [
  {
    id: 'log_sample_1',
    plantId: 'plt_sample_1',
    plantName: '书房清风小绿',
    actionType: 'water',
    actionName: '浇水',
    date: '2026-09-12',
    time: '08:20',
    note: '见干见湿，沿盆边浇透'
  },
  {
    id: 'log_sample_2',
    plantId: 'plt_sample_2',
    plantName: '阳台紫蝶',
    actionType: 'water',
    actionName: '浇水',
    date: '2026-09-08',
    time: '09:20',
    note: '水苔浸盆补水'
  },
  {
    id: 'log_sample_3',
    plantId: 'plt_sample_3',
    plantName: '案头冰灯',
    actionType: 'water',
    actionName: '浇水',
    date: '2026-09-05',
    time: '20:10',
    note: '颗粒土浇透'
  }
];
