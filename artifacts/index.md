# Artifact index

Derived from the store (artifacts/**/*.json) by scripts/New-ArtifactIndex.ps1 - regenerate,
never hand-edit; the JSON records are the source of truth. Freshness contract (#20): this
file is gated fresh at PR-to-main and push-to-main; on dev it may lag the store by a
dispatch batch between regenerations.

| subject | kind | at | outcome | file |
|---|---|---|---|---|
| 2026-07-21-design-v0-round1-REJECT | returned | 2026-07-22T03:44:34-04:00 | REJECT | reviews/2026-07-21-design-v0-round1-REJECT.json |
| 2026-07-22-design-v0-round2-REJECT | returned | 2026-07-22T03:44:34-04:00 | REJECT | reviews/2026-07-22-design-v0-round2-REJECT.json |
| 2026-07-22-harness-design-round1-REJECT | returned | 2026-07-22T04:15:55-04:00 | REJECT | reviews/2026-07-22-harness-design-round1-REJECT.json |
| 2026-07-22-harness-design-round2-REJECT | returned | 2026-07-22T04:54:19-04:00 | REJECT | reviews/2026-07-22-harness-design-round2-REJECT.json |
| 2026-07-22-harness-design-round3-REJECT | returned | 2026-07-22T05:19:03-04:00 | REJECT | reviews/2026-07-22-harness-design-round3-REJECT.json |
| 2026-07-22-harness-design-round4-REJECT-ESCALATED | returned | 2026-07-22T05:44:06-04:00 | REJECT | reviews/2026-07-22-harness-design-round4-REJECT-ESCALATED.json |
| 2026-07-22-harness-design-round5-REJECT | returned | 2026-07-22T06:48:16-04:00 | REJECT | reviews/2026-07-22-harness-design-round5-REJECT.json |
| 2026-07-22-harness-spec-round1-REJECT | returned | 2026-07-22T07:34:06-04:00 | REJECT | reviews/2026-07-22-harness-spec-round1-REJECT.json |
| 2026-07-22-harness-spec-round2-DELTA-REJECT | returned | 2026-07-22T08:03:24-04:00 | REJECT | reviews/2026-07-22-harness-spec-round2-DELTA-REJECT.json |
| 2026-07-22-harness-spec-round3-CONFIRM-REJECT | returned | 2026-07-22T08:15:35-04:00 | REJECT | reviews/2026-07-22-harness-spec-round3-CONFIRM-REJECT.json |
| 2026-07-22-harness-spec-round4-APPROVE | returned | 2026-07-22T08:18:58-04:00 | APPROVE | reviews/2026-07-22-harness-spec-round4-APPROVE.json |
| 2026-07-22-plan-review-car1-round1 | returned | 2026-07-22T09:02:29-04:00 | REJECT | reviews/2026-07-22-plan-review-car1-round1.json |
| 2026-07-22-plan-review-car1-round2 | returned | 2026-07-22T09:31:34-04:00 | REJECT | reviews/2026-07-22-plan-review-car1-round2.json |
| 2026-07-22-plan-review-car1-round3 | returned | 2026-07-22T09:38:41-04:00 | APPROVE-WITH-REBASE-LIST | reviews/2026-07-22-plan-review-car1-round3.json |
| 2026-07-22-car1-review-round1 | returned | 2026-07-22T10:07:24-04:00 | REJECT | reviews/2026-07-22-car1-review-round1.json |
| 2026-07-22-car1-review-round2 | returned | 2026-07-22T10:15:52-04:00 | APPROVE | reviews/2026-07-22-car1-review-round2.json |
| 2026-07-22-car2-plan-review-round1 | returned | 2026-07-22T11:06:52-04:00 | REJECT | reviews/2026-07-22-car2-plan-review-round1.json |
| 2026-07-22-car2-plan-review-round2-drill | returned | 2026-07-22T11:24:23-04:00 | REJECT | reviews/2026-07-22-car2-plan-review-round2-drill.json |
| 2026-07-22-car2-plan-review-round3 | returned | 2026-07-22T11:28:42-04:00 | APPROVE | reviews/2026-07-22-car2-plan-review-round3.json |
| 2026-07-22-car2-review-round1 | returned | 2026-07-22T12:30:37-04:00 | REJECT | reviews/2026-07-22-car2-review-round1.json |
| 2026-07-22-car2-review-round2 | returned | 2026-07-22T12:38:59-04:00 | APPROVE | reviews/2026-07-22-car2-review-round2.json |
| a83a3fefd4659985e | dispatched | 2026-07-22T16:39:57Z |  | a83a3fefd4659985e/dispatched-20260722T163957Z.json |
| a83a3fefd4659985e | returned | 2026-07-22T16:40:01Z | done | a83a3fefd4659985e/returned-20260722T164001Z.json |
| a62054a9e0f804eae | dispatched | 2026-07-22T16:41:19Z |  | a62054a9e0f804eae/dispatched-20260722T164119Z.json |
| a62054a9e0f804eae | returned | 2026-07-22T16:41:25Z | done | a62054a9e0f804eae/returned-20260722T164125Z.json |
| a6940e01dae1edf78 | returned | 2026-07-22T16:52:06Z | CONFIRM | a6940e01dae1edf78/returned-20260722T165206Z.json |
| 2026-07-22-hotfix-confirm | returned | 2026-07-22T12:53:46-04:00 | CONFIRM | reviews/2026-07-22-hotfix-confirm.json |
| ac32f4e635f031ebe | dispatched | 2026-07-22T16:58:56Z |  | ac32f4e635f031ebe/dispatched-20260722T165856Z.json |
| ac32f4e635f031ebe | returned | 2026-07-22T17:14:19Z | REJECT | ac32f4e635f031ebe/returned-20260722T171419Z.json |
| 2026-07-22-car3-plan-review-round1 | returned | 2026-07-22T13:18:44-04:00 | REJECT | reviews/2026-07-22-car3-plan-review-round1.json |
| ac32f4e635f031ebe | returned | 2026-07-22T17:23:30Z | APPROVE | ac32f4e635f031ebe/returned-20260722T172330Z.json |
| 2026-07-22-car3-plan-review-round2 | returned | 2026-07-22T13:24:07-04:00 | APPROVE | reviews/2026-07-22-car3-plan-review-round2.json |
| ad3eddb772ccb7a93 | dispatched | 2026-07-22T17:24:53Z |  | ad3eddb772ccb7a93/dispatched-20260722T172453Z.json |
| ad3eddb772ccb7a93 | returned | 2026-07-22T17:54:34Z | done | ad3eddb772ccb7a93/returned-20260722T175434Z.json |
| a3f05aecaa3d550e2 | dispatched | 2026-07-22T17:55:41Z |  | a3f05aecaa3d550e2/dispatched-20260722T175541Z.json |
| a3f05aecaa3d550e2 | returned | 2026-07-22T18:16:48Z | REJECT | a3f05aecaa3d550e2/returned-20260722T181648Z.json |
| 2026-07-22-car3-review-round1 | returned | 2026-07-22T14:18:03-04:00 | REJECT | reviews/2026-07-22-car3-review-round1.json |
| ad3eddb772ccb7a93 | returned | 2026-07-22T18:30:25Z | done | ad3eddb772ccb7a93/returned-20260722T183025Z.json |
| a3f05aecaa3d550e2 | returned | 2026-07-22T18:42:11Z | APPROVE-WITH-REBASE-LIST | a3f05aecaa3d550e2/returned-20260722T184211Z.json |
| aefe2954995877480 | dispatched | 2026-07-22T20:34:58Z |  | aefe2954995877480/dispatched-20260722T203458Z.json |
| aefe2954995877480 | returned | 2026-07-22T20:45:22Z | APPROVE | aefe2954995877480/returned-20260722T204522Z.json |
| a128ea355478cd378 | dispatched | 2026-07-22T20:46:00Z |  | a128ea355478cd378/dispatched-20260722T204600Z.json |
| aefe2954995877480 | returned | 2026-07-22T21:01:33Z | APPROVE | aefe2954995877480/returned-20260722T210133Z.json |
| a128ea355478cd378 | returned | 2026-07-22T21:02:06Z | REJECT | a128ea355478cd378/returned-20260722T210206Z.json |
| aefe2954995877480 | returned | 2026-07-22T21:06:54Z | APPROVE | aefe2954995877480/returned-20260722T210654Z.json |
| a12fbbe2b1592101a | dispatched | 2026-07-22T21:08:03Z |  | a12fbbe2b1592101a/dispatched-20260722T210803Z.json |
| a128ea355478cd378 | returned | 2026-07-22T21:12:29Z | APPROVE | a128ea355478cd378/returned-20260722T211229Z.json |
| a12fbbe2b1592101a | returned | 2026-07-22T21:16:57Z | APPROVE | a12fbbe2b1592101a/returned-20260722T211657Z.json |
| a44127012b765aa15 | dispatched | 2026-07-22T21:59:48Z |  | a44127012b765aa15/dispatched-20260722T215948Z.json |
| a44127012b765aa15 | returned | 2026-07-22T22:09:23Z | REJECT | a44127012b765aa15/returned-20260722T220923Z.json |
| a44127012b765aa15 | returned | 2026-07-22T22:16:25Z | APPROVE-WITH-REBASE-LIST | a44127012b765aa15/returned-20260722T221625Z.json |
| ac99647694fc5795c | dispatched | 2026-07-22T22:18:03Z |  | ac99647694fc5795c/dispatched-20260722T221803Z.json |
| ac99647694fc5795c | returned | 2026-07-22T22:39:51Z | APPROVE | ac99647694fc5795c/returned-20260722T223951Z.json |
| ab533387b9d497ac7 | dispatched | 2026-07-22T22:40:48Z |  | ab533387b9d497ac7/dispatched-20260722T224048Z.json |
| ab533387b9d497ac7 | returned | 2026-07-22T22:53:25Z | APPROVE | ab533387b9d497ac7/returned-20260722T225325Z.json |
| ad224da7ad28ced57 | dispatched | 2026-07-22T23:10:04Z |  | ad224da7ad28ced57/dispatched-20260722T231004Z.json |
| ad224da7ad28ced57 | returned | 2026-07-22T23:20:38Z | CONFIRM | ad224da7ad28ced57/returned-20260722T232038Z.json |
| acc761f0add2b0af2 | dispatched | 2026-07-23T10:57:08Z |  | acc761f0add2b0af2/dispatched-20260723T105708Z.json |
| acc761f0add2b0af2 | returned | 2026-07-23T11:05:42Z | done | acc761f0add2b0af2/returned-20260723T110542Z.json |
| ac7d81bda8f23f2a6 | dispatched | 2026-07-23T11:06:47Z |  | ac7d81bda8f23f2a6/dispatched-20260723T110647Z.json |
| ac7d81bda8f23f2a6 | returned | 2026-07-23T11:15:41Z | APPROVE | ac7d81bda8f23f2a6/returned-20260723T111541Z.json |
| a663c067d1d565f02 | dispatched | 2026-07-23T11:40:35Z |  | a663c067d1d565f02/dispatched-20260723T114035Z.json |
| a663c067d1d565f02 | returned | 2026-07-23T11:52:37Z | REJECT | a663c067d1d565f02/returned-20260723T115237Z.json |
| a4374d0904d8f8534 | dispatched | 2026-07-23T12:15:27Z |  | a4374d0904d8f8534/dispatched-20260723T121527Z.json |
| a4374d0904d8f8534 | returned | 2026-07-23T12:23:49Z | APPROVE | a4374d0904d8f8534/returned-20260723T122349Z.json |
| acc25b07aa67ecf2c | dispatched | 2026-07-23T12:28:28Z |  | acc25b07aa67ecf2c/dispatched-20260723T122828Z.json |
| acc25b07aa67ecf2c | returned | 2026-07-23T12:35:49Z | REJECT | acc25b07aa67ecf2c/returned-20260723T123549Z.json |
