import { describe, beforeEach, it, expect } from '@ohos/hypium';
import {
  exists, tap, waitFor, openApp, goto, backToTabs, sleep, shot, countText,
  typeInto, relaunch, logStep
} from './UiDriver';

/** 状态持久化：记录后重启（回桌面再冷启动）仍应保留 */
export default function persistenceTest() {
  describe('BBoxPersistence', () => {
    beforeEach(async () => {
      await openApp();
    });

    it('PS-01_care_log_survives_relaunch', 0, async () => {
      logStep('PS-01 养护打卡后重启：足迹仍保留');
      await goto('花园');
      await tap('浇水');
      await sleep(900);
      await goto('今日');
      const before: number = await countText('为「');
      expect(before > 0).assertTrue();

      await relaunch();
      await sleep(1200);
      await goto('今日');
      const after: number = await countText('为「');
      expect(after >= before).assertTrue();
      expect(await exists('最近养护足迹')).assertTrue();
      await shot('PS-01_after_relaunch');
    });

    it('PS-02_new_plant_survives_relaunch', 0, async () => {
      logStep('PS-02 新增植物后重启：花园仍能看到');
      const nick: string = '持久化测试花';
      await goto('花园');
      await tap('＋ 添置新绿');
      expect(await waitFor('花草爱称 / 昵称', 6000)).assertTrue();
      expect(await typeInto('TextInput', 0, nick)).assertTrue();
      expect(await tap('确认收进我的花园')).assertTrue();
      expect(await waitFor('我的花园', 6000)).assertTrue();
      await sleep(600);
      expect(await exists(nick)).assertTrue();

      await relaunch();
      await sleep(1200);
      await goto('花园');
      expect(await exists(nick)).assertTrue();
      await shot('PS-02_plant_after_relaunch');
    });

    it('PS-03_new_diary_survives_relaunch', 0, async () => {
      logStep('PS-03 新增日记后重启：日记本仍能看到');
      const title: string = '持久化测试日记';
      await goto('今日');
      await tap('记篇日记');
      expect(await waitFor('日记标题', 6000)).assertTrue();
      expect(await typeInto('TextInput', 0, title)).assertTrue();
      expect(await typeInto('TextArea', 0, '自动化测试写入的内容')).assertTrue();
      expect(await tap('写下这抹绿意')).assertTrue();
      await sleep(1000);

      await relaunch();
      await sleep(1200);
      await goto('雅舍');
      await tap('📖 日记本');
      await sleep(800);
      expect(await exists(title)).assertTrue();
      await shot('PS-03_diary_after_relaunch');
    });
  });
}
