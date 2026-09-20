// Seeds the `OnboardingQuizz` Firestore collection from the catalogue bundled
// with the app (assets/data/onboarding_quizz.json), one document per step.
//
// By default only the missing steps are created, so the edits made in the
// Firestore console are never overwritten. Pass --overwrite to replace every
// step with the bundled version.
//
//   GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json node seed.mjs [--overwrite] [--dry-run]

import { readFile } from 'node:fs/promises';
import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? 'recipe-ai-5e261';
const COLLECTION = 'OnboardingQuizz';
const CATALOGUE_PATH = new URL(
  '../../assets/data/onboarding_quizz.json',
  import.meta.url,
);

const overwrite = process.argv.includes('--overwrite');
const dryRun = process.argv.includes('--dry-run');

const catalogue = JSON.parse(await readFile(CATALOGUE_PATH, 'utf8'));

initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
const firestore = getFirestore();

for (const [stepKey, step] of Object.entries(catalogue)) {
  const ref = firestore.collection(COLLECTION).doc(stepKey);
  const exists = (await ref.get()).exists;

  if (exists && !overwrite) {
    console.log(`= ${stepKey}: already in Firestore, kept`);
    continue;
  }

  if (!dryRun) await ref.set(step);
  console.log(
    `${exists ? '~' : '+'} ${stepKey}: ${exists ? 'overwritten' : 'created'}` +
      (dryRun ? ' (dry run)' : ''),
  );
}

console.log(`Done on project ${PROJECT_ID}.`);
