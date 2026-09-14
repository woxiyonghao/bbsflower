/**
 * 花盆档案模型（我的花园）
 */
export interface PlantModel {
  id: string;
  speciesId: string;           // 关联的百科花种 ID
  name: string;                // 花种名称，如 绿萝
  nickname: string;            // 爱称，如 阳台一号小绿
  location: string;            // 摆放位置：阳台、客厅、窗台、书房、卧室、办公室等
  potSize: string;             // 花盆尺寸：微型、小盆(10-15cm)、中盆(16-25cm)、大盆(25cm+)
  icon: string;                // 图标 Emoji
  acquireDate: string;         // 入手日期 YYYY-MM-DD
  waterInterval: number;       // 浇水周期（天）
  fertilizeInterval: number;   // 施肥周期（天）
  lastWaterDate: string;       // 上次浇水日期 YYYY-MM-DD
  lastFertilizeDate: string;   // 上次施肥日期 YYYY-MM-DD
  healthStatus: string;        // 健康状态：thriving(郁郁葱葱), healthy(生长良好), attention(稍需关注), dormant(冬季休眠)
  notes: string;               // 备注
  isFavorite: boolean;         // 是否置顶/收藏
  imageUri?: string;           // 本地成长代表照
}
