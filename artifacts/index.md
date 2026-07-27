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
| acc25b07aa67ecf2c | returned | 2026-07-23T12:41:43Z | APPROVE | acc25b07aa67ecf2c/returned-20260723T124143Z.json |
| aa93fdf486b9ff91b | dispatched | 2026-07-23T12:47:02Z |  | aa93fdf486b9ff91b/dispatched-20260723T124702Z.json |
| aa93fdf486b9ff91b | returned | 2026-07-23T13:00:00Z | REJECT | aa93fdf486b9ff91b/returned-20260723T130000Z.json |
| aa93fdf486b9ff91b | returned | 2026-07-23T13:10:07Z | APPROVE | aa93fdf486b9ff91b/returned-20260723T131007Z.json |
| a01ab6d06808d2ab4 | dispatched | 2026-07-23T13:20:29Z |  | a01ab6d06808d2ab4/dispatched-20260723T132029Z.json |
| a01ab6d06808d2ab4 | returned | 2026-07-23T13:33:41Z | REJECT | a01ab6d06808d2ab4/returned-20260723T133341Z.json |
| a01ab6d06808d2ab4 | returned | 2026-07-23T13:43:06Z | APPROVE | a01ab6d06808d2ab4/returned-20260723T134306Z.json |
| a184e26ee16e704ae | dispatched | 2026-07-23T13:45:29Z |  | a184e26ee16e704ae/dispatched-20260723T134529Z.json |
| train:board-v0 | intent | 2026-07-23T13:46:05Z |  | train-board-v0/intent-20260723T134605Z.json |
| a184e26ee16e704ae | returned | 2026-07-23T14:02:52Z | done | a184e26ee16e704ae/returned-20260723T140252Z.json |
| a10f39e071e8e4b7b | dispatched | 2026-07-23T14:04:01Z |  | a10f39e071e8e4b7b/dispatched-20260723T140401Z.json |
| a10f39e071e8e4b7b | returned | 2026-07-23T14:14:19Z | APPROVE | a10f39e071e8e4b7b/returned-20260723T141419Z.json |
| train:board-v0 | intent | 2026-07-23T14:16:14Z |  | train-board-v0/intent-20260723T141614Z.json |
| a3a95266490ba928d | dispatched | 2026-07-23T14:18:10Z |  | a3a95266490ba928d/dispatched-20260723T141810Z.json |
| a3a95266490ba928d | returned | 2026-07-23T14:35:38Z | done | a3a95266490ba928d/returned-20260723T143538Z.json |
| a21c8b80339f1c8fd | dispatched | 2026-07-23T14:36:39Z |  | a21c8b80339f1c8fd/dispatched-20260723T143639Z.json |
| a21c8b80339f1c8fd | returned | 2026-07-23T14:51:00Z | REJECT | a21c8b80339f1c8fd/returned-20260723T145100Z.json |
| a3a95266490ba928d | returned | 2026-07-23T14:55:04Z | done | a3a95266490ba928d/returned-20260723T145504Z.json |
| a21c8b80339f1c8fd | returned | 2026-07-23T14:58:10Z | APPROVE | a21c8b80339f1c8fd/returned-20260723T145810Z.json |
| train:board-v0 | intent | 2026-07-23T14:58:55Z |  | train-board-v0/intent-20260723T145855Z.json |
| a0ff9e48c78041347 | dispatched | 2026-07-23T15:00:36Z |  | a0ff9e48c78041347/dispatched-20260723T150036Z.json |
| accbde6200eebcfc4 | dispatched | 2026-07-23T15:07:53Z |  | accbde6200eebcfc4/dispatched-20260723T150753Z.json |
| accbde6200eebcfc4 | returned | 2026-07-23T15:11:58Z | REJECT | accbde6200eebcfc4/returned-20260723T151158Z.json |
| accbde6200eebcfc4 | returned | 2026-07-23T15:14:39Z | APPROVE | accbde6200eebcfc4/returned-20260723T151439Z.json |
| a0ff9e48c78041347 | returned | 2026-07-23T15:38:45Z | done | a0ff9e48c78041347/returned-20260723T153845Z.json |
| ae55c4d7156cb410b | dispatched | 2026-07-23T15:40:14Z |  | ae55c4d7156cb410b/dispatched-20260723T154014Z.json |
| ae55c4d7156cb410b | returned | 2026-07-23T15:57:24Z | REJECT | ae55c4d7156cb410b/returned-20260723T155724Z.json |
| a5b5e3024cb48da0c | dispatched | 2026-07-23T16:15:32Z |  | a5b5e3024cb48da0c/dispatched-20260723T161532Z.json |
| a5b5e3024cb48da0c | returned | 2026-07-23T16:20:43Z | REJECT | a5b5e3024cb48da0c/returned-20260723T162043Z.json |
| a5b5e3024cb48da0c | returned | 2026-07-23T16:26:45Z | APPROVE | a5b5e3024cb48da0c/returned-20260723T162645Z.json |
| a0ff9e48c78041347 | returned | 2026-07-23T16:33:03Z | done | a0ff9e48c78041347/returned-20260723T163303Z.json |
| ae55c4d7156cb410b | returned | 2026-07-23T16:42:49Z | APPROVE | ae55c4d7156cb410b/returned-20260723T164249Z.json |
| train:board-v0 | intent | 2026-07-23T16:43:55Z |  | train-board-v0/intent-20260723T164355Z.json |
| a093b1df791839bd5 | dispatched | 2026-07-23T16:46:59Z |  | a093b1df791839bd5/dispatched-20260723T164659Z.json |
| a093b1df791839bd5 | returned | 2026-07-23T17:27:39Z | done | a093b1df791839bd5/returned-20260723T172739Z.json |
| a581cde8b292e2378 | dispatched | 2026-07-23T17:29:09Z |  | a581cde8b292e2378/dispatched-20260723T172909Z.json |
| a581cde8b292e2378 | returned | 2026-07-23T17:46:55Z | REJECT | a581cde8b292e2378/returned-20260723T174655Z.json |
| a093b1df791839bd5 | returned | 2026-07-23T17:58:00Z | done | a093b1df791839bd5/returned-20260723T175800Z.json |
| a581cde8b292e2378 | returned | 2026-07-23T18:04:34Z | APPROVE | a581cde8b292e2378/returned-20260723T180434Z.json |
| train:board-v0 | intent | 2026-07-23T18:05:31Z |  | train-board-v0/intent-20260723T180531Z.json |
| a82c503743b088b8e | dispatched | 2026-07-23T18:08:23Z |  | a82c503743b088b8e/dispatched-20260723T180823Z.json |
| a82c503743b088b8e | returned | 2026-07-23T18:45:03Z | done | a82c503743b088b8e/returned-20260723T184503Z.json |
| a9da976d441bd2a50 | dispatched | 2026-07-23T18:46:33Z |  | a9da976d441bd2a50/dispatched-20260723T184633Z.json |
| a9da976d441bd2a50 | returned | 2026-07-23T19:00:31Z | APPROVE | a9da976d441bd2a50/returned-20260723T190031Z.json |
| train:board-v0 | intent | 2026-07-23T19:01:56Z |  | train-board-v0/intent-20260723T190156Z.json |
| a3bfb5c078bd8da96 | dispatched | 2026-07-23T20:43:54Z |  | a3bfb5c078bd8da96/dispatched-20260723T204354Z.json |
| a3bfb5c078bd8da96 | returned | 2026-07-23T20:55:53Z | done | a3bfb5c078bd8da96/returned-20260723T205553Z.json |
| a5d6678f863493256 | dispatched | 2026-07-23T20:58:14Z |  | a5d6678f863493256/dispatched-20260723T205814Z.json |
| aadb0a6abcbe764ed | dispatched | 2026-07-23T21:11:21Z |  | aadb0a6abcbe764ed/dispatched-20260723T211121Z.json |
| a5d6678f863493256 | returned | 2026-07-23T21:16:29Z | APPROVE | a5d6678f863493256/returned-20260723T211629Z.json |
| aadb0a6abcbe764ed | returned | 2026-07-23T21:42:19Z | done-with-findings | aadb0a6abcbe764ed/returned-20260723T214219Z.json |
| a21a8117ae140fa72 | dispatched | 2026-07-23T21:44:36Z |  | a21a8117ae140fa72/dispatched-20260723T214436Z.json |
| a21a8117ae140fa72 | returned | 2026-07-23T22:01:02Z | APPROVE | a21a8117ae140fa72/returned-20260723T220102Z.json |
| a38588f299202d415 | dispatched | 2026-07-24T09:56:50Z |  | a38588f299202d415/dispatched-20260724T095650Z.json |
| a38588f299202d415 | returned | 2026-07-24T10:11:47Z | done-with-findings | a38588f299202d415/returned-20260724T101147Z.json |
| ab8b2e7effb839f82 | dispatched | 2026-07-24T10:13:18Z |  | ab8b2e7effb839f82/dispatched-20260724T101318Z.json |
| ab8b2e7effb839f82 | returned | 2026-07-24T10:30:30Z | REJECT | ab8b2e7effb839f82/returned-20260724T103030Z.json |
| 51-fix-car-r1 | dispatched | 2026-07-24T17:10:20Z |  | 51-fix-car-r1/dispatched-20260724T171020Z.json |
| 51-fix-car-r1 | returned | 2026-07-24T17:26:29Z | done-with-findings | 51-fix-car-r1/returned-20260724T172629Z.json |
| 51-fix-review-r1 | dispatched | 2026-07-24T17:27:29Z |  | 51-fix-review-r1/dispatched-20260724T172729Z.json |
| 51-fix-review-r1 | returned | 2026-07-24T17:38:46Z | done-with-findings | 51-fix-review-r1/returned-20260724T173846Z.json |
| 52-hygiene-car-r1 | dispatched | 2026-07-24T19:21:45Z |  | 52-hygiene-car-r1/dispatched-20260724T192145Z.json |
| 53-guard-car-r1 | dispatched | 2026-07-24T19:22:28Z |  | 53-guard-car-r1/dispatched-20260724T192228Z.json |
| 53-guard-car-r1 | returned | 2026-07-24T19:29:25Z | completed | 53-guard-car-r1/returned-20260724T192925Z.json |
| 53-guard-review-r1 | dispatched | 2026-07-24T19:30:07Z |  | 53-guard-review-r1/dispatched-20260724T193007Z.json |
| 52-hygiene-review-r1 | dispatched | 2026-07-24T19:33:18Z |  | 52-hygiene-review-r1/dispatched-20260724T193318Z.json |
| 53-guard-review-r1 | returned | 2026-07-24T19:34:23Z | approve-for-merge | 53-guard-review-r1/returned-20260724T193423Z.json |
| 52-hygiene-car-r1 | returned | 2026-07-24T19:42:01Z | completed | 52-hygiene-car-r1/returned-20260724T194201Z.json |
| 52-hygiene-review-r1 | returned | 2026-07-24T19:43:20Z | approve-for-merge | 52-hygiene-review-r1/returned-20260724T194320Z.json |
| tooling-41-39-38-car-r1 | dispatched | 2026-07-25T14:18:38Z |  | tooling-41-39-38-car-r1/dispatched-20260725T141838Z.json |
| tooling-41-39-38-review-r1 | dispatched | 2026-07-25T14:30:31Z |  | tooling-41-39-38-review-r1/dispatched-20260725T143031Z.json |
| tooling-41-39-38-car-r1 | returned | 2026-07-25T14:35:59Z | done-with-findings | tooling-41-39-38-car-r1/returned-20260725T143559Z.json |
| tooling-41-39-38-review-r1 | returned | 2026-07-25T14:36:05Z | approve-for-merge | tooling-41-39-38-review-r1/returned-20260725T143605Z.json |
| 41-suite-split-car-r1 | dispatched | 2026-07-25T17:36:32Z |  | 41-suite-split-car-r1/dispatched-20260725T173632Z.json |
| 41-suite-split-review-r1 | dispatched | 2026-07-25T17:42:47Z |  | 41-suite-split-review-r1/dispatched-20260725T174247Z.json |
| 41-suite-split-car-r1 | returned | 2026-07-25T17:46:46Z | completed | 41-suite-split-car-r1/returned-20260725T174646Z.json |
| 41-suite-split-review-r1 | returned | 2026-07-25T17:46:53Z | approve-for-merge | 41-suite-split-review-r1/returned-20260725T174653Z.json |
| register-35-36-37-car-r1 | dispatched | 2026-07-25T22:56:44Z |  | register-35-36-37-car-r1/dispatched-20260725T225644Z.json |
| register-35-36-37-review-r1 | dispatched | 2026-07-25T23:07:44Z |  | register-35-36-37-review-r1/dispatched-20260725T230744Z.json |
| register-35-36-37-car-r1 | returned | 2026-07-25T23:13:21Z | completed | register-35-36-37-car-r1/returned-20260725T231321Z.json |
| register-35-36-37-review-r1 | returned | 2026-07-25T23:13:32Z | approve-for-merge | register-35-36-37-review-r1/returned-20260725T231332Z.json |
| af5f0b4f753a8f9d7 | dispatched | 2026-07-26T11:19:26Z |  | af5f0b4f753a8f9d7/dispatched-20260726T111926Z.json |
| af5f0b4f753a8f9d7 | returned | 2026-07-26T11:54:02Z | done | af5f0b4f753a8f9d7/returned-20260726T115402Z.json |
| ad18f715d2df17fe5 | dispatched | 2026-07-26T11:55:40Z |  | ad18f715d2df17fe5/dispatched-20260726T115540Z.json |
| ad18f715d2df17fe5 | returned | 2026-07-26T12:15:18Z | REJECT | ad18f715d2df17fe5/returned-20260726T121518Z.json |
| af5f0b4f753a8f9d7 | returned | 2026-07-26T12:44:27Z | done-with-findings | af5f0b4f753a8f9d7/returned-20260726T124427Z.json |
| ad18f715d2df17fe5 | returned | 2026-07-26T13:01:18Z | REJECT | ad18f715d2df17fe5/returned-20260726T130118Z.json |
| af5f0b4f753a8f9d7 | returned | 2026-07-26T13:15:18Z | done | af5f0b4f753a8f9d7/returned-20260726T131518Z.json |
| ad18f715d2df17fe5 | returned | 2026-07-26T13:25:24Z | APPROVE | ad18f715d2df17fe5/returned-20260726T132524Z.json |
| af5f0b4f753a8f9d7 | returned | 2026-07-26T13:41:01Z | done | af5f0b4f753a8f9d7/returned-20260726T134101Z.json |
| a5234897d26a4e293 | dispatched | 2026-07-26T13:42:24Z |  | a5234897d26a4e293/dispatched-20260726T134224Z.json |
| a5234897d26a4e293 | returned | 2026-07-26T13:56:54Z | REJECT | a5234897d26a4e293/returned-20260726T135654Z.json |
| af5f0b4f753a8f9d7 | returned | 2026-07-26T14:07:31Z | done | af5f0b4f753a8f9d7/returned-20260726T140731Z.json |
| a5234897d26a4e293 | returned | 2026-07-26T14:16:59Z | APPROVE | a5234897d26a4e293/returned-20260726T141659Z.json |
| a94fcd2c88a32d991 | dispatched | 2026-07-26T14:20:48Z |  | a94fcd2c88a32d991/dispatched-20260726T142048Z.json |
| a94fcd2c88a32d991 | returned | 2026-07-26T14:25:14Z | done | a94fcd2c88a32d991/returned-20260726T142514Z.json |
| ae2db65a15d4b58a2 | dispatched | 2026-07-26T14:25:52Z |  | ae2db65a15d4b58a2/dispatched-20260726T142552Z.json |
| ae2db65a15d4b58a2 | returned | 2026-07-26T14:34:19Z | APPROVE | ae2db65a15d4b58a2/returned-20260726T143419Z.json |
| ae17d6a1ac77dc264 | dispatched | 2026-07-26T14:40:42Z |  | ae17d6a1ac77dc264/dispatched-20260726T144042Z.json |
| ae17d6a1ac77dc264 | returned | 2026-07-26T14:55:44Z | CONFIRM | ae17d6a1ac77dc264/returned-20260726T145544Z.json |
| ac9289f01a6a15ced | dispatched | 2026-07-26T15:09:01Z |  | ac9289f01a6a15ced/dispatched-20260726T150901Z.json |
| ac9289f01a6a15ced | returned | 2026-07-26T15:44:58Z | done-with-findings | ac9289f01a6a15ced/returned-20260726T154458Z.json |
| afe1a2c703e2e615e | dispatched | 2026-07-26T15:46:01Z |  | afe1a2c703e2e615e/dispatched-20260726T154601Z.json |
| afe1a2c703e2e615e | returned | 2026-07-26T16:08:09Z | REJECT | afe1a2c703e2e615e/returned-20260726T160809Z.json |
| ac9289f01a6a15ced | returned | 2026-07-26T16:19:48Z | done | ac9289f01a6a15ced/returned-20260726T161948Z.json |
| afe1a2c703e2e615e | returned | 2026-07-26T16:26:50Z | APPROVE | afe1a2c703e2e615e/returned-20260726T162650Z.json |
| a076bf6c0a94e302f | dispatched | 2026-07-26T16:29:35Z |  | a076bf6c0a94e302f/dispatched-20260726T162935Z.json |
| aae450cea6c656f9e | dispatched | 2026-07-26T16:30:01Z |  | aae450cea6c656f9e/dispatched-20260726T163001Z.json |
| aae450cea6c656f9e | returned | 2026-07-26T16:41:16Z | done | aae450cea6c656f9e/returned-20260726T164116Z.json |
| a076bf6c0a94e302f | returned | 2026-07-26T16:41:18Z | done | a076bf6c0a94e302f/returned-20260726T164118Z.json |
| a67cb0075007e7753 | dispatched | 2026-07-26T16:42:13Z |  | a67cb0075007e7753/dispatched-20260726T164213Z.json |
| a7fbcee7ccaec45d8 | dispatched | 2026-07-26T16:42:41Z |  | a7fbcee7ccaec45d8/dispatched-20260726T164241Z.json |
| a67cb0075007e7753 | returned | 2026-07-26T16:54:23Z | REJECT | a67cb0075007e7753/returned-20260726T165423Z.json |
| a7fbcee7ccaec45d8 | returned | 2026-07-26T16:58:03Z | REJECT | a7fbcee7ccaec45d8/returned-20260726T165803Z.json |
| a076bf6c0a94e302f | returned | 2026-07-26T17:06:11Z | done | a076bf6c0a94e302f/returned-20260726T170611Z.json |
| aae450cea6c656f9e | returned | 2026-07-26T17:09:50Z | done | aae450cea6c656f9e/returned-20260726T170950Z.json |
| a67cb0075007e7753 | returned | 2026-07-26T17:14:57Z | REJECT | a67cb0075007e7753/returned-20260726T171457Z.json |
| a7fbcee7ccaec45d8 | returned | 2026-07-26T17:18:07Z | REJECT | a7fbcee7ccaec45d8/returned-20260726T171807Z.json |
| a076bf6c0a94e302f | returned | 2026-07-26T17:28:56Z | done | a076bf6c0a94e302f/returned-20260726T172856Z.json |
| aae450cea6c656f9e | returned | 2026-07-26T17:30:49Z | done | aae450cea6c656f9e/returned-20260726T173049Z.json |
| a67cb0075007e7753 | returned | 2026-07-26T17:36:09Z | APPROVE | a67cb0075007e7753/returned-20260726T173609Z.json |
| a7fbcee7ccaec45d8 | returned | 2026-07-26T17:39:07Z | APPROVE | a7fbcee7ccaec45d8/returned-20260726T173907Z.json |
| aef700efc7cc87570 | dispatched | 2026-07-26T17:49:48Z |  | aef700efc7cc87570/dispatched-20260726T174948Z.json |
| aef700efc7cc87570 | returned | 2026-07-26T18:19:00Z | done-with-findings | aef700efc7cc87570/returned-20260726T181900Z.json |
| a13a5df25c7c6bf77 | dispatched | 2026-07-26T18:20:10Z |  | a13a5df25c7c6bf77/dispatched-20260726T182010Z.json |
| a13a5df25c7c6bf77 | returned | 2026-07-26T18:43:22Z | REJECT | a13a5df25c7c6bf77/returned-20260726T184322Z.json |
| aef700efc7cc87570 | returned | 2026-07-26T18:57:53Z | done | aef700efc7cc87570/returned-20260726T185753Z.json |
| a13a5df25c7c6bf77 | returned | 2026-07-26T19:06:33Z | REJECT | a13a5df25c7c6bf77/returned-20260726T190633Z.json |
| aef700efc7cc87570 | returned | 2026-07-26T19:09:54Z | done | aef700efc7cc87570/returned-20260726T190954Z.json |
| a13a5df25c7c6bf77 | returned | 2026-07-26T19:20:15Z | REJECT | a13a5df25c7c6bf77/returned-20260726T192015Z.json |
| aef700efc7cc87570 | returned | 2026-07-26T19:31:24Z | done | aef700efc7cc87570/returned-20260726T193124Z.json |
| a13a5df25c7c6bf77 | returned | 2026-07-26T19:39:26Z | APPROVE | a13a5df25c7c6bf77/returned-20260726T193926Z.json |
| a19ef853c23ba9742 | dispatched | 2026-07-26T19:41:35Z |  | a19ef853c23ba9742/dispatched-20260726T194135Z.json |
| a19ef853c23ba9742 | returned | 2026-07-26T20:03:47Z | done-with-findings | a19ef853c23ba9742/returned-20260726T200347Z.json |
| ae6398614a373c807 | dispatched | 2026-07-26T20:04:47Z |  | ae6398614a373c807/dispatched-20260726T200447Z.json |
| ae6398614a373c807 | returned | 2026-07-26T20:21:10Z | REJECT | ae6398614a373c807/returned-20260726T202110Z.json |
| a19ef853c23ba9742 | returned | 2026-07-26T20:33:11Z | done | a19ef853c23ba9742/returned-20260726T203311Z.json |
| ae6398614a373c807 | returned | 2026-07-26T20:41:06Z | APPROVE | ae6398614a373c807/returned-20260726T204106Z.json |
| a19ef853c23ba9742 | returned | 2026-07-26T20:43:18Z | done | a19ef853c23ba9742/returned-20260726T204318Z.json |
| a19ef853c23ba9742 | returned | 2026-07-26T20:45:17Z | done | a19ef853c23ba9742/returned-20260726T204517Z.json |
| acb10c126ac3a7488 | dispatched | 2026-07-26T20:47:31Z |  | acb10c126ac3a7488/dispatched-20260726T204731Z.json |
| acb10c126ac3a7488 | returned | 2026-07-26T21:30:05Z | done-with-findings | acb10c126ac3a7488/returned-20260726T213005Z.json |
| a678b799208107386 | dispatched | 2026-07-26T21:32:10Z |  | a678b799208107386/dispatched-20260726T213210Z.json |
| a678b799208107386 | returned | 2026-07-26T21:59:02Z | REJECT | a678b799208107386/returned-20260726T215902Z.json |
| acb10c126ac3a7488 | returned | 2026-07-26T22:18:41Z | done | acb10c126ac3a7488/returned-20260726T221841Z.json |
| a678b799208107386 | returned | 2026-07-26T22:34:41Z | REJECT | a678b799208107386/returned-20260726T223441Z.json |
| acb10c126ac3a7488 | returned | 2026-07-26T22:41:46Z | done | acb10c126ac3a7488/returned-20260726T224146Z.json |
| a678b799208107386 | returned | 2026-07-26T22:50:37Z | APPROVE | a678b799208107386/returned-20260726T225037Z.json |
| ab2bd332be0eebc2c | dispatched | 2026-07-26T23:01:41Z |  | ab2bd332be0eebc2c/dispatched-20260726T230141Z.json |
| ab2bd332be0eebc2c | returned | 2026-07-26T23:35:12Z | SUCCESS | ab2bd332be0eebc2c/returned-20260726T233512Z.json |
| a965df3347dae4a72 | dispatched | 2026-07-26T23:36:21Z |  | a965df3347dae4a72/dispatched-20260726T233621Z.json |
| a965df3347dae4a72 | returned | 2026-07-26T23:57:18Z | REJECT | a965df3347dae4a72/returned-20260726T235718Z.json |
| ab2bd332be0eebc2c | returned | 2026-07-27T00:31:48Z | SUCCESS | ab2bd332be0eebc2c/returned-20260727T003148Z.json |
| a965df3347dae4a72 | returned | 2026-07-27T00:46:27Z | REJECT | a965df3347dae4a72/returned-20260727T004627Z.json |
| ab2bd332be0eebc2c | returned | 2026-07-27T01:01:07Z | SUCCESS | ab2bd332be0eebc2c/returned-20260727T010107Z.json |
| a965df3347dae4a72 | returned | 2026-07-27T01:10:03Z | REJECT-ESCALATED | a965df3347dae4a72/returned-20260727T011003Z.json |
| ab2bd332be0eebc2c | returned | 2026-07-27T01:28:30Z | SUCCESS | ab2bd332be0eebc2c/returned-20260727T012830Z.json |
| acf9a7451ccf63594 | dispatched | 2026-07-27T01:29:22Z |  | acf9a7451ccf63594/dispatched-20260727T012922Z.json |
| acf9a7451ccf63594 | returned | 2026-07-27T01:44:06Z | REJECT | acf9a7451ccf63594/returned-20260727T014406Z.json |
| ab2bd332be0eebc2c | returned | 2026-07-27T01:51:27Z | SUCCESS | ab2bd332be0eebc2c/returned-20260727T015127Z.json |
| acf9a7451ccf63594 | returned | 2026-07-27T01:58:29Z | APPROVE | acf9a7451ccf63594/returned-20260727T015829Z.json |
| a0ea6918ba39a1bda | dispatched | 2026-07-27T02:08:48Z |  | a0ea6918ba39a1bda/dispatched-20260727T020848Z.json |
| a0ea6918ba39a1bda | returned | 2026-07-27T02:35:44Z | success | a0ea6918ba39a1bda/returned-20260727T023544Z.json |
| aa9858b26c4f2f91e | dispatched | 2026-07-27T02:36:44Z |  | aa9858b26c4f2f91e/dispatched-20260727T023644Z.json |
| aa9858b26c4f2f91e | returned | 2026-07-27T02:53:57Z | REJECT | aa9858b26c4f2f91e/returned-20260727T025357Z.json |
