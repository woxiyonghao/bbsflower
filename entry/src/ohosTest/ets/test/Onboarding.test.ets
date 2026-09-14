import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { exists, tap, waitFor, openApp, relaunch, backToTabs, sleep, shot, logStep } from './UiDriver';

/**
 * 隐私合规首启流程。运行前需清空应用数据（宿主脚本执行 `bm clean`），
 * 以保证「首次冷启动」这一前置条件成立。
 */
export default function onboardingTest() {
  describe('BBoxOnboarding', () => {
    beforeEach(async () => {
      await relaunch();
    });

    it('ON-01_first_launch_shows_privacy_dialog', 0, async () => {
      logStep('ON-01 首次冷启动应弹出隐私指引');
      const dialog: boolean = await waitFor('花伴录服务与隐私指引', 8000);
      expect(dialog).assertTrue();
      const agreeBtn: boolean = await exists('同意并开启');
      expect(agreeBtn).assertTrue();
      const declineBtn: boolean = await exists('不同意并退出');
      expect(declineBtn).assertTrue();
      await shot('ON-01_privacy_dialog');
    });

    it('ON-02_privacy_policy_readable_before_agree', 0, async () => {
      logStep('ON-02 未同意前可查阅隐私政策全文，返回后仍停留在同意页');
      const opened: boolean = await tap('《隐私政策与用户协议》');
      expect(opened).assertTrue();
      const policyPage: boolean = await waitFor('纯单机离线承诺', 6000);
      expect(policyPage).assertTrue();
      await shot('ON-02_privacy_policy_page');

      await backToTabs();
      const stillDialog: boolean = await waitFor('同意并开启', 4000);
      expect(stillDialog).assertTrue();
    });

    it('ON-03_agree_enters_home', 0, async () => {
      logStep('ON-03 同意后进入主界面');
      const dialog: boolean = await waitFor('同意并开启', 8000);
      expect(dialog).assertTrue();
      await tap('同意并开启');
      const home: boolean = await waitFor('琉璃花语', 8000);
      expect(home).assertTrue();
      expect(await exists('雅舍')).assertTrue();
      expect(await exists('今日待办养护')).assertTrue();
      await shot('ON-03_home_after_agree');
    });

    it('ON-04_agreement_persists_after_relaunch', 0, async () => {
      logStep('ON-04 重启后不再弹窗');
      await backToTabs();
      await relaunch();
      const dialogGone: boolean = !(await exists('同意并开启'));
      expect(dialogGone).assertTrue();
      expect(await waitFor('琉璃花语', 6000)).assertTrue();
      await openApp();
    });

    it('ON-05_home_anchor_after_onboarding', 0, async () => {
      logStep('ON-05 同意态下冷启动直达首页');
      await openApp();
      expect(await exists('每日花语')).assertTrue();
      expect(await exists('最近养护足迹')).assertTrue();
      await shot('ON-05_home_after_onboarding');
      await sleep(200);
    });
  });
}
