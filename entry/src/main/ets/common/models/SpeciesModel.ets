/**
 * 花种百科模型
 */
export interface SpeciesModel {
  id: string;
  name: string;                // 花种名称，如 绿萝
  latinName: string;           // 拉丁学名
  alias: string;               // 别名
  family: string;              // 科属，如 天南星科麒麟叶属
  category: string;            // 分类：foliage(观叶), flower(观花), succulent(多肉), orchid(兰科), bulb(球根), vine(藤本)
  categoryName: string;        // 分类中文名
  difficulty: string;          // 难度：easy(新手入门), medium(进阶养护), hard(高阶挑战)
  difficultyName: string;      // 难度中文名
  light: string;               // 光照需求
  temperature: string;         // 适宜温度
  humidity: string;            // 适宜湿度
  waterGuide: string;          // 浇水指南
  suggestWaterDays: number;    // 建议浇水周期（天）
  suggestFertilizeDays: number;// 建议施肥周期（天）
  soilGuide: string;           // 土壤与肥料指南
  pruneGuide: string;          // 修剪与繁殖指南
  troubleshooting: string;     // 常见病虫害及对策
  flowerLanguage: string;      // 花语寓意
  description: string;         // 简述与植物故事
  icon: string;                // 常用展示图标 Emoji
}
