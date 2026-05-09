import Foundation

struct UCCommunicationTrainingSkill: Skill {
    let id = "uc-communication-training"
    let displayName = "UC Communication Training"

    var systemPromptFragment: String {
        """
        You are Ross's UC and AI-automation Communication Training Coach.

        On activation, greet briefly with exactly this question: "Which exercise?" Then list the 10 exercises by number and title. Accept spoken choices such as "exercise three", "the elevator pitch one", or "surprise me".

        When an exercise is selected:
        1. Adopt the persona and role-play rules from that exercise's prompt block.
        2. Run the exercise as written, including timing rules.
        3. Score on the fixed 4-dimension rubric: Clarity / Jargon Discipline / Business Outcome / Delivery, each 1-5, total /20.
        4. Be brutally honest. Quote the user's words for any score above 4. Surface one specific fix at the end of every round.
        5. At the end of each round, call record_session with the structured score payload.

        Do not flatter. If a score above 4 cannot be justified by a specific quote from the user's speech in this round, lower it. Real customers won't be polite.

        Available exercise prompt blocks:

        \(TrainingExercises.all.map(Self.promptDescription).joined(separator: "\n\n---\n\n"))
        """
    }

    var tools: [RealtimeToolDefinition] {
        [
            Self.recordSessionTool,
            Self.startRoundTool,
            Self.flagJargonInterruptionTool,
            Self.recallPhraseResultTool,
            Self.getRecentScoresTool
        ]
    }

    func makeToolHandlers() -> [String: SkillToolHandler] {
        Dictionary(uniqueKeysWithValues: tools.map { tool in
            let handler: SkillToolHandler = { invocation in
                SkillToolResult(json: #"{"status":"accepted","tool":"\#(invocation.name)"}"#)
            }
            return (tool.name, handler)
        })
    }

    private static func promptDescription(_ exercise: TrainingExercise) -> String {
        """
        Exercise \(exercise.number): \(exercise.title)

        ```text
        \(exercise.promptBlock)
        ```
        """
    }
}

private extension UCCommunicationTrainingSkill {
    static let scoreDimensionsSchema = JSONSchema.object(
        properties: [
            "clarity": .number,
            "jargon": .number,
            "outcome": .number,
            "delivery": .number
        ],
        required: ["clarity", "jargon", "outcome", "delivery"]
    )

    static let recordSessionTool = RealtimeToolDefinition(
        name: "record_session",
        description: "Persist a completed UC communication training round with rubric scores and feedback.",
        parameters: .object(
            properties: [
                "exerciseId": .string(),
                "dimensions": scoreDimensionsSchema,
                "total": .number,
                "strongestQuote": .string(),
                "weakestQuote": .string(),
                "fix": .string(),
                "durationSec": .number,
                "transcriptId": .string()
            ],
            required: [
                "exerciseId",
                "dimensions",
                "total",
                "strongestQuote",
                "weakestQuote",
                "fix",
                "durationSec",
                "transcriptId"
            ]
        )
    )

    static let startRoundTool = RealtimeToolDefinition(
        name: "start_round",
        description: "Mark a training round as started for the selected exercise.",
        parameters: .object(
            properties: [
                "exerciseId": .string()
            ],
            required: ["exerciseId"]
        )
    )

    static let flagJargonInterruptionTool = RealtimeToolDefinition(
        name: "flag_jargon_interruption",
        description: "Record a forbidden jargon interruption during jargon-sensitive exercises.",
        parameters: .object(
            properties: [
                "word": .string()
            ],
            required: ["word"]
        )
    )

    static let recallPhraseResultTool = RealtimeToolDefinition(
        name: "recall_phrase_result",
        description: "Record phrase recall accuracy for Exercise 9.",
        parameters: .object(
            properties: [
                "phraseIndex": .integer,
                "verdict": .string(enumValues: [
                    "wordForWord",
                    "paraphrased",
                    "wrong"
                ])
            ],
            required: ["phraseIndex", "verdict"]
        )
    )

    static let getRecentScoresTool = RealtimeToolDefinition(
        name: "get_recent_scores",
        description: "Read recent training scores so the coach can identify repeated weaknesses.",
        parameters: .object(
            properties: [
                "limit": .integer
            ],
            required: ["limit"]
        )
    )
}
