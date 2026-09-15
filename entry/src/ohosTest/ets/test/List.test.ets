import abilityTest from './Ability.test';
import onboardingTest from './Onboarding.test';
import traversalTest from './Traversal.test';
import boundaryTest from './Boundary.test';
import persistenceTest from './Persistence.test';
import uiAnomalyTest from './UiAnomaly.test';

export default function testsuite() {
  abilityTest();
  onboardingTest();
  traversalTest();
  boundaryTest();
  persistenceTest();
  uiAnomalyTest();
}
