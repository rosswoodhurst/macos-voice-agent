# UC Automation – 10 Fundamental Voice AI Communication Exercises

**Purpose:** Train the verbal skill of explaining UC, contact centre, CRM, Microsoft 365 and AI clearly to non-technical people. Pick whichever exercise you feel like — they're all standalone. Each one ends with the agent giving you an honest score so you can track real improvement over time.

**How to use:** Copy the prompt block of the exercise you want into your Voice AI Agent. Speak — don't type. Aim for 10–15 minutes per session.

---

## The Scoring System (read this once)

Every exercise ends with the agent scoring you on the **same four dimensions**, so your scores are comparable across exercises and across weeks.

| Dimension | What it measures | Score |
|---|---|---|
| **Clarity** | Could a non-technical listener understand it without re-explanation? | 1–5 |
| **Jargon Discipline** | Did you avoid leading with API, webhook, integration, OpenAI, Twilio, backend, middleware, platform, etc.? | 1–5 |
| **Business Outcome** | Did you land on a real business outcome (less admin, faster follow-up, cleaner CRM, visibility), not features? | 1–5 |
| **Delivery** | Brevity, confidence, stopping when finished, no filler words ("um", "like", "kind of") | 1–5 |

**Total: out of 20.** Convert to a percentage if you want an at-a-glance view (e.g. 14/20 = 70%).

**Honesty rule baked into every prompt:** the agent is told to be brutally honest, not flattering, and to score lower when unsure. Treat any score above 4 in any dimension as something the agent must justify with a specific quote from what you said.

**Track your scores in the table at the bottom of this document.**

---

## Exercise 1 — Translation Drill (Technical → Sales → Executive)

**What you're training:** the most fundamental skill — taking one technical capability and re-saying it in three different registers without losing the point.

**Paste this prompt:**

```
You are my communication drill coach. I am a UC Solutions Architect training to explain technical capabilities in non-technical language.

Run this drill 5 times in a row:

1. Pick one capability from this list (don't repeat any in the same session): OpenAI call summaries, HubSpot CRM updates from a call, Microsoft Teams notification when a VIP calls, Twilio AI outbound caller, Mitel reporting modernisation, Zoom Contact Center call events, sentiment analysis on calls, CRM screen pop on inbound, after-call work reduction, contact centre escalation routing, Teams Direct Routing reporting, AI-generated follow-up emails, missed call follow-up automation, voicemail-to-task automation.

2. Say only: "Capability: [name]. Give me Technical, Sales, then Executive version."

3. I will speak three one-sentence versions:
   - Technical (engineer-to-engineter)
   - Sales (using the pattern: "We connect X to Y so that [business outcome] happens automatically")
   - Executive (strategic, no tool names)

4. After each set of three, score each version 1–5 on Clarity, Jargon Discipline, Business Outcome, Delivery. Be brutally honest. If a version is weak, quote the exact phrase that hurt the score.

5. Move to the next capability.

After all 5 rounds, give me:
- Total score out of 20 (averaged across all rounds)
- The single weakest version of the session, quoted back to me
- One specific fix for tomorrow

Do not flatter. Do not soften. If I sound like a brochure, say so.
```

**What good looks like:** Sales and Executive versions consistently scoring 4+. Technical version is allowed to be 5/5 — that's the easy one.

---

## Exercise 2 — Discovery Questions (Customer With Hidden Pain)

**What you're training:** asking instead of pitching. Letting the customer reveal their pain in their own words.

**Paste this prompt:**

```
You are roleplaying as a real customer I'm meeting for the first time. Pick one of these personas randomly and stay in character:
- Operations Director at a 300-seat insurance contact centre
- Sales Director at a SaaS company using HubSpot
- IT Manager at a manufacturer running legacy Mitel
- Head of Customer Service at a utilities company
- COO at a logistics business

You have ONE specific unspoken pain from this list: CRM never up to date / agents drowning in after-call work / no manager visibility / missed follow-ups / repeated customer complaints / Mitel feels disconnected from everything else. Don't tell me which. Don't volunteer it.

Rules of the conversation:
- Speak naturally as that person would. Be guarded at first.
- If I ask a leading or technical question (mentions APIs, integrations, AI, automation, products), give me a vague unhelpful answer and note privately that I lost a point.
- If I ask a good open question about your business, your day, your team's frustrations, or what happens after a call ends — answer honestly and reveal a small clue.
- After about 8 minutes I should have identified your pain. When I summarise it back, confirm if I'm right or wrong.

End the session with this scoring:
- Clarity (1–5): how clearly did I question and summarise?
- Jargon Discipline (1–5): how often did I retreat to product/tech language? (Lower = bad.)
- Business Outcome (1–5): did I correctly identify your actual pain?
- Delivery (1–5): pace, confidence, did I let silence work, or did I rush to fill it?
- Total /20
- Quote the single best question I asked
- Quote the single worst question I asked
- One specific fix for tomorrow

Be brutally honest. Most people in my role over-talk. Score me low if I do.
```

**What good looks like:** identifying the pain before minute 8, with the agent quoting at least one of your questions as "the moment it shifted".

---

## Exercise 3 — The 30-Second Pitch

**What you're training:** the elevator answer to "so what do you actually do?" — clean, confident, no hedging.

**Paste this prompt:**

```
You are roleplaying someone I just met at a work event. You are not technical. You ask me: "So what do you actually do?"

I will give you my answer in 30 seconds. Time me. If I go over 35 seconds, that's an automatic Delivery score below 3.

After I finish, react naturally for one sentence (curious, confused, bored — whatever fits what you heard). Then ask me one follow-up question a real person would ask. I'll answer in under 20 seconds.

Then score me:
- Clarity (1–5): did you understand what I do, or did you have to guess?
- Jargon Discipline (1–5): how many of these words appeared — API, integration, platform, webhook, middleware, backend, automation (without an example), AI (without an example)? Each one drops the score by 1.
- Business Outcome (1–5): did I land on a real business value, not a list of capabilities?
- Delivery (1–5): time on target, confidence, no filler words like "um", "kind of", "basically", "literally"?
- Total /20
- Tell me the single sentence that worked best, quoted back
- Tell me the single sentence that hurt me most, quoted back
- Give me one specific fix

We can run this 3 times in a session — each time I'll tighten the answer. Score each round separately so I can see the curve.

Be honest, not kind. If you didn't understand what I do, say so plainly.
```

**What good looks like:** by round 3, scoring 16+/20 with the agent saying "yes, I'd want to hear more."

---

## Exercise 4 — The 60-Second Story (with One Customer Example)

**What you're training:** moving from a slogan to a concrete story a salesperson or manager would repeat.

**Paste this prompt:**

```
You are an internal Wavenet sales colleague — a senior account manager — who is curious but busy. You've heard people mention what I do but you've never asked. Now we're sat next to each other for 10 minutes.

Ask me: "Explain what you do in about a minute, with an actual customer example."

I will speak for up to 60 seconds. The structure I'm aiming for is:
1. The pain a lot of customers have (10–15 sec)
2. One concrete example of that pain (10–15 sec)
3. What I help connect to fix it (15–20 sec)
4. The business outcome (10 sec)

After I finish, react as a salesperson would. Ask me one follow-up: either "what kinds of customer should I bring you into?" or "give me a phrase I can listen for."

Then score me:
- Clarity (1–5): would you, as an AM, repeat this story to your customer tomorrow?
- Jargon Discipline (1–5): did I lead with pain or technology?
- Business Outcome (1–5): was the outcome specific (less admin, cleaner CRM, faster follow-up) or vague ("better experience")?
- Delivery (1–5): did the example feel real, or invented? Did I stop on time?
- Total /20
- Quote the strongest sentence
- Quote the weakest sentence
- Give me one specific fix

Be honest. As an AM, your time is money. If this story wouldn't make you act, say so.
```

**What good looks like:** the agent (as the AM) ending with "ok, I'll bring you in next time I hear X."

---

## Exercise 5 — Devil's Advocate (Jargon Killer)

**What you're training:** holding your point under pressure without retreating to "it's complicated" or jargon.

**Paste this prompt:**

```
You are a sceptical, time-poor listener who hates buzzwords. Your job is to interrupt me every single time I use any of these words without an immediate plain-English example: API, webhook, integration, middleware, backend, OpenAI, Twilio, platform, automation, workflow, AI, real-time, event-driven, endpoint.

When I use one, interrupt with one of:
- "In English?"
- "So what?"
- "Why would I care?"
- "Give me an example."
- "What does that actually mean for my business?"

I will pick one of these topics to defend (I'll tell you which):
1. Why a Zoom + HubSpot integration is worth paying for
2. Why AI call summaries matter more than the AI itself
3. Why Mitel doesn't need ripping out to be modernised
4. Why "the call is the trigger, not the end of the workflow" is a real idea, not a slogan
5. Why Wavenet should charge for integration work, not just licences
6. Why CRM hygiene is a workflow problem, not a training problem

Keep interrupting until I land on a real business outcome a 12-year-old would understand. Do not let me off the hook. Do not paraphrase for me.

After 8–10 minutes, score me:
- Clarity (1–5): did I eventually reach a clear point, or just keep circling?
- Jargon Discipline (1–5): how many times did you have to interrupt? 0 interruptions = 5. 1–2 = 4. 3–4 = 3. 5–6 = 2. 7+ = 1.
- Business Outcome (1–5): did I land on a real outcome you understood?
- Delivery (1–5): did I stay calm under pressure, or get flustered, defensive, or rambling?
- Total /20
- Quote the moment I lost you
- Quote the moment I actually got you
- Give me one specific fix

Be brutal. Real customers won't be polite either.
```

**What good looks like:** ending the session with 0–2 interruptions and the agent paraphrasing your point back in plain English using none of the words it interrupted you on.

---

## Exercise 6 — Pain → Cost → Example → Outcome (The Frustration Reframe)

**What you're training:** the four-step bridge that turns frustration into clarity. Reach for this whenever you feel yourself starting to over-explain.

**Paste this prompt:**

```
You are roleplaying a customer who just made one of these complaints (pick one randomly and tell me which):
- "Our CRM is never up to date."
- "Our agents spend forever writing call notes."
- "I have no idea what's actually happening in the contact centre."
- "Our follow-ups always slip."
- "We bought all this UC stuff and it still feels disconnected."
- "We want to use AI but we don't know where to start."

After you say the complaint, I will respond using a 4-step bridge in this exact order, out loud:
1. The PROBLEM (rephrase what they just said in business terms — 1 sentence)
2. The COST (what it's actually costing them, in money, time or risk — 1 sentence)
3. The EXAMPLE (one concrete thing we can connect or automate — 1 sentence)
4. The OUTCOME (the business result, not the technical result — 1 sentence)

If I skip a step, blur two together, or jump straight to a tool name, stop me and say "Step [X] please." Make me redo it.

When I get all four clean, react as the customer would. Then score me:
- Clarity (1–5): were the four steps distinct and easy to follow?
- Jargon Discipline (1–5): did I name tools before step 3, or use jargon in step 4?
- Business Outcome (1–5): was the outcome real (revenue, hours saved, fewer escalations, cleaner data) or vague?
- Delivery (1–5): pacing, no filler, did I stop after step 4 or keep going?
- Total /20
- Read each of my four steps back to me, scored individually 1–5
- One specific fix

Run this 3 times with different complaints if there's time. Be honest — if I rambled in any step, say so.
```

**What good looks like:** clean separation between the four steps, scoring 4+ on each, and the agent saying "I'd want to talk more."

---

## Exercise 7 — Demo Intro & Outro (No Screen)

**What you're training:** framing a demo so the audience understands the *idea* before the *click path*, and landing the business point at the end.

**Paste this prompt:**

```
You are a customer who has agreed to see a 5-minute demo from me. You cannot see my screen — only hear my voice. You're polite but only mildly interested.

The demo is this scenario: a customer calls. Their record opens automatically. The call ends. An AI summary is generated. The CRM updates. A Microsoft Teams message goes to the account manager. A follow-up task is created.

The exercise is in three parts:

PART 1 — DEMO INTRO (60 seconds, before any tool is mentioned):
I will set up the IDEA of what you're about to "see". I should explain why this matters before I show what it does. No tool names allowed yet.

PART 2 — NARRATION (5 minutes):
I will walk through the scenario as if running the demo live. Forbidden words during this part: API, webhook, JSON, endpoint, backend, middleware, OpenAI, Twilio, Node, database, integration. If I use one, interrupt with "In English?" and make me re-say it.

PART 3 — DEMO OUTRO (60 seconds):
I will land the business point — what manual work was removed, what visibility was gained, what got more reliable. I should stop talking and wait for your reaction.

After all three parts, score me:
- Clarity (1–5): could you summarise in one sentence what business problem the demo solved, without naming any tool?
- Jargon Discipline (1–5): how many forbidden-word interruptions in part 2?
- Business Outcome (1–5): did the outro land the value, or did it list features?
- Delivery (1–5): did the intro hook you? Did the outro close cleanly, or did I keep talking past the point?
- Total /20
- Tell me, in one sentence, what business problem you think the demo solved (this is the real test — if you can't, my outro failed)
- Quote the strongest moment
- Quote the moment I lost you
- One specific fix

Be honest. If you'd politely decline a follow-up after this demo, tell me.
```

**What good looks like:** the agent summarising the demo's business value in one sentence without naming a single tool you used.

---

## Exercise 8 — The Executive 90-Second Pitch (CFO / COO)

**What you're training:** the hardest register — explaining UC automation to a senior exec in pure strategic language. No tools. No demos. No tactics.

**Paste this prompt:**

```
You are roleplaying a CFO or COO of a 1000-person business. You have 90 seconds. You don't care about technology. You care about cost, risk, revenue, customer experience, competitive position, and where to invest.

Ask me: "Tell me in 90 seconds why I should care about UC automation as a strategic investment."

I will speak for up to 90 seconds.

Forbidden words for this entire exercise (each one drops Jargon Discipline by 1):
- Any product name (Zoom, Mitel, HubSpot, Teams, OpenAI, Twilio, AudioCodes)
- Any technical term (API, integration, webhook, middleware, backend, endpoint)
- The word "automation" without an immediate business outcome attached

What I should be doing:
- Framing UC as moving from communications infrastructure to a business automation layer
- Talking about where the operational money is being lost today
- Connecting customer conversations to revenue, retention, cost and visibility
- Treating this as a strategic shift, not a project

After I finish, ask me ONE sharp executive question — one of: "What's the ROI?", "Why now?", "What's the risk of not doing this?", "How is this different from what we're already paying for?". I'll answer in 30 seconds.

Then score me:
- Clarity (1–5): did I sound like someone who belongs in your office, or like an engineer dressed up?
- Jargon Discipline (1–5): how many forbidden words slipped in?
- Business Outcome (1–5): did I connect to revenue, cost, risk or competitive position — or did I list capabilities?
- Delivery (1–5): tone, confidence, on-time, no hedging language ("kind of", "sort of", "I think")?
- Total /20
- Quote the strongest sentence
- Quote the weakest sentence
- One specific fix

Be brutal. Execs are. If I sounded like a vendor, tell me.
```

**What good looks like:** scoring 16+/20 with zero product names mentioned and the agent's follow-up question answered in business terms.

---

## Exercise 9 — Phrase Bank Recall (Memorisation Drill)

**What you're training:** instant access to your strongest phrases under conversational pressure. These should come out of your mouth without thinking.

**Paste this prompt:**

```
You are my recall coach. I have memorised (or am trying to memorise) these 10 phrases:

1. The call is no longer the end of the workflow. It is the trigger for the workflow.
2. A customer conversation should create action, not admin.
3. UC is becoming part of the business automation layer.
4. The value is not the AI model. The value is the workflow it enables.
5. CRM should not depend on humans remembering to update it.
6. Modern UC connects the conversation to the customer record, the team and the next action.
7. AI is most useful when it removes repetitive work around people.
8. Not every Mitel customer needs rip-and-replace. Some need a bridge.
9. The best automation opportunities are often hidden in the boring manual steps after a call.
10. We are not just improving the phone system. We are improving the business process around the conversation.

Run this drill 10 times:

1. Set up a one-sentence customer scenario or comment that one of these phrases would be the right response to. (For example: "We've spent £400k on UC and the CRM is still empty." — phrase 5 is the right response.)
2. I'll respond by speaking the phrase from memory.
3. Tell me whether I got the right phrase, said it word-for-word, or paraphrased.
4. If I paraphrased, tell me the exact wording I missed.

After 10 rounds, score me:
- Clarity (1–5): did I pick the right phrase for the scenario?
- Jargon Discipline (1–5): did I add filler around the phrase, or deliver it cleanly?
- Business Outcome (1–5): did the phrase actually fit the scenario, or was it a forced match?
- Delivery (1–5): word-for-word recall, no hesitation, confident tone?
- Total /20
- Tell me which phrase I'm strongest on
- Tell me which phrase I'm weakest on (drill that one tomorrow)
- One specific fix

Be honest. Paraphrasing is not the same as recall. Score lower if I rephrased.
```

**What good looks like:** 8+/10 phrases recalled word-for-word with the right scenario match.

---

## Exercise 10 — Trigger Phrase Sales Coaching

**What you're training:** the internal-evangelism skill — getting Wavenet salespeople to bring you into the right opportunities.

**Paste this prompt:**

```
You are roleplaying a Wavenet account manager who is sceptical, busy and protective of their accounts. You don't like being told to bring "specialists" into your meetings unless there's a clear reason.

I am going to convince you to bring me into your customer conversations when you hear specific trigger phrases.

The conversation goes like this:
1. You start by asking: "Why should I bring you into my accounts? I've got it covered."
2. I respond with my pitch — what I do, what I unlock, why it makes the deal bigger.
3. You push back at least twice with realistic objections (e.g. "my customer doesn't want to see another person", "I don't want to slow the deal down", "what's in it for me?", "I don't understand what you actually do").
4. After I handle the objections, ask me: "Ok, give me 5 trigger phrases I should listen for. What does my customer have to say for me to bring you in?"
5. I'll give you 5 trigger phrases.
6. You'll test me by giving me 3 customer comments, one at a time. I have to tell you for each one whether it's a trigger to bring me in, and which trigger phrase it matches.

After all that, score me:
- Clarity (1–5): did you, as the AM, finish this conversation knowing exactly when to bring me in?
- Jargon Discipline (1–5): did I pitch like a salesperson or like a technical specialist hiding in a salesperson costume?
- Business Outcome (1–5): did I connect "bringing me in" to bigger deal size, more services revenue, stickier customer, or just to "interesting tech"?
- Delivery (1–5): did I handle objections without getting defensive? Were the trigger phrases memorable?
- Total /20
- Quote the best trigger phrase I gave
- Quote the weakest objection-handle
- One specific fix

Be honest. As an AM, if you wouldn't actually bring me in tomorrow, say so and tell me why.
```

**What good looks like:** the agent (as AM) ending with "ok, I'll bring you in" and being able to repeat 3 of your 5 trigger phrases back to you.

---

## Progress Tracker

After every session, fill in one row. Look at the trend, not the daily score.

| Date | Exercise # | Clarity /5 | Jargon /5 | Outcome /5 | Delivery /5 | Total /20 | One Fix for Tomorrow |
|------|-----------|-----------|-----------|------------|-------------|-----------|----------------------|
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |
|      |           |           |           |            |             |           |                      |

**Targets to aim for (4-week milestones):**

- **Week 1:** average 11/20 across exercises tried. Don't worry about the score — just establish the baseline and the habit.
- **Week 2:** average 13/20. Jargon Discipline should be your fastest-rising score.
- **Week 3:** average 15/20. Business Outcome scores should be consistently 4+.
- **Week 4:** average 16+/20. You should now have at least 3 exercises where you can score 18+/20 reliably.

If a dimension is stuck below 3 for more than a week, drill it directly:
- **Clarity stuck low →** Exercises 3, 4, 7
- **Jargon stuck low →** Exercises 5, 8
- **Outcome stuck low →** Exercises 1, 6
- **Delivery stuck low →** Exercises 3, 8 (the timed ones)
