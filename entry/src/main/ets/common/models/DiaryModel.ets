/**
 * 植物成长日记与观察笔记模型
 */
export interface DiaryModel {
  id: string;
  plantId: string;             // 关联植物 ID（为空表示全局花园日记）
  plantName: string;           // 植物名称
  title: string;               // 日记标题
  content: string;             // 心得与观察正文
  date: string;                // 记录日期 YYYY-MM-DD
  time: string;                // 时间 HH:mm
  tag: string;                 // 标签：sprout(萌发新芽), bloom(繁花盛开), observe(日常观察), repot(翻盆记录), pest(病虫害斗争)
  tagName: string;             // 标签中文名
  mood: string;                // 心情 Emoji：🌱、🌸、💧、☀️、🥰
  imageUri?: string;           // 本地成长照片
}
