import Foundation

public struct SeedData {
    public static let initialExercises: [Exercise] = [
        // MARK: - CHEST
        Exercise(name: "Barbell Bench Press", muscleGroup: .chest),
        Exercise(name: "Dumbbell Bench Press", muscleGroup: .chest),
        Exercise(name: "Incline Barbell Bench Press", muscleGroup: .chest),
        Exercise(name: "Incline Dumbbell Press", muscleGroup: .chest),
        Exercise(name: "Decline Bench Press", muscleGroup: .chest),
        Exercise(name: "Dumbbell Fly", muscleGroup: .chest),
        Exercise(name: "Cable Chest Fly", muscleGroup: .chest),
        Exercise(name: "Pec Deck", muscleGroup: .chest),
        Exercise(name: "Machine Chest Press", muscleGroup: .chest),
        Exercise(name: "Push-Up", muscleGroup: .chest),
        Exercise(name: "Chest Press", muscleGroup: .chest),
        Exercise(name: "Smith Machine Bench Press", muscleGroup: .chest),

        // MARK: - SHOULDERS
        Exercise(name: "Barbell Overhead Press", muscleGroup: .shoulders),
        Exercise(name: "Dumbbell Shoulder Press", muscleGroup: .shoulders),
        Exercise(name: "Arnold Press", muscleGroup: .shoulders),
        Exercise(name: "Machine Shoulder Press", muscleGroup: .shoulders),
        Exercise(name: "Dumbbell Lateral Raise", muscleGroup: .shoulders),
        Exercise(name: "Cable Lateral Raise", muscleGroup: .shoulders),
        Exercise(name: "Front Raise", muscleGroup: .shoulders),
        Exercise(name: "Rear Delt Fly", muscleGroup: .shoulders),
        Exercise(name: "Reverse Pec Deck", muscleGroup: .shoulders),
        Exercise(name: "Face Pull", muscleGroup: .shoulders),
        Exercise(name: "Upright Row", muscleGroup: .shoulders),

        // MARK: - BACK
        Exercise(name: "Pull-Up", muscleGroup: .back),
        Exercise(name: "Chin-Up", muscleGroup: .back),
        Exercise(name: "Lat Pulldown", muscleGroup: .back),
        Exercise(name: "Close-Grip Lat Pulldown", muscleGroup: .back),
        Exercise(name: "Seated Cable Row", muscleGroup: .back),
        Exercise(name: "Barbell Row", muscleGroup: .back),
        Exercise(name: "Dumbbell Row", muscleGroup: .back),
        Exercise(name: "Chest-Supported Row", muscleGroup: .back),
        Exercise(name: "T-Bar Row", muscleGroup: .back),
        Exercise(name: "Machine Row", muscleGroup: .back),
        Exercise(name: "Straight-Arm Pulldown", muscleGroup: .back),
        Exercise(name: "Single-Arm Cable Row", muscleGroup: .back),
        Exercise(name: "Deadlift", muscleGroup: .back),
        Exercise(name: "Romanian Deadlift", muscleGroup: .back),

        // MARK: - BICEPS
        Exercise(name: "Barbell Curl", muscleGroup: .biceps),
        Exercise(name: "EZ-Bar Curl", muscleGroup: .biceps),
        Exercise(name: "Dumbbell Curl", muscleGroup: .biceps),
        Exercise(name: "Hammer Curl", muscleGroup: .biceps),
        Exercise(name: "Incline Dumbbell Curl", muscleGroup: .biceps),
        Exercise(name: "Preacher Curl", muscleGroup: .biceps),
        Exercise(name: "Cable Curl", muscleGroup: .biceps),
        Exercise(name: "Concentration Curl", muscleGroup: .biceps),
        Exercise(name: "Machine Curl", muscleGroup: .biceps),
        Exercise(name: "Bayesian Curl", muscleGroup: .biceps),

        // MARK: - TRICEPS
        Exercise(name: "Triceps Pushdown", muscleGroup: .triceps),
        Exercise(name: "Rope Pushdown", muscleGroup: .triceps),
        Exercise(name: "Bar Pushdown", muscleGroup: .triceps),
        Exercise(name: "Overhead Triceps Extension", muscleGroup: .triceps),
        Exercise(name: "Dumbbell Overhead Extension", muscleGroup: .triceps),
        Exercise(name: "Skull Crushers", muscleGroup: .triceps),
        Exercise(name: "Close-Grip Bench Press", muscleGroup: .triceps),
        Exercise(name: "Cable Overhead Extension", muscleGroup: .triceps),
        Exercise(name: "Triceps Dip", muscleGroup: .triceps),
        Exercise(name: "Assisted Dip", muscleGroup: .triceps),

        // MARK: - LEGS — QUADRICEPS
        Exercise(name: "Barbell Squat", muscleGroup: .quads),
        Exercise(name: "Front Squat", muscleGroup: .quads),
        Exercise(name: "Hack Squat", muscleGroup: .quads),
        Exercise(name: "Leg Press", muscleGroup: .quads),
        Exercise(name: "Bulgarian Split Squat", muscleGroup: .quads),
        Exercise(name: "Walking Lunges", muscleGroup: .quads),
        Exercise(name: "Dumbbell Lunges", muscleGroup: .quads),
        Exercise(name: "Leg Extension", muscleGroup: .quads),
        Exercise(name: "Goblet Squat", muscleGroup: .quads),
        Exercise(name: "Smith Machine Squat", muscleGroup: .quads),

        // MARK: - HAMSTRINGS / GLUTES
        Exercise(name: "Stiff-Leg Deadlift", muscleGroup: .hamstringsGlutes),
        Exercise(name: "Leg Curl", muscleGroup: .hamstringsGlutes),
        Exercise(name: "Seated Leg Curl", muscleGroup: .hamstringsGlutes),
        Exercise(name: "Lying Leg Curl", muscleGroup: .hamstringsGlutes),
        Exercise(name: "Hip Thrust", muscleGroup: .hamstringsGlutes),
        Exercise(name: "Glute Bridge", muscleGroup: .hamstringsGlutes),
        Exercise(name: "Good Morning", muscleGroup: .hamstringsGlutes),
        Exercise(name: "Cable Kickback", muscleGroup: .hamstringsGlutes),

        // MARK: - CALVES
        Exercise(name: "Standing Calf Raise", muscleGroup: .calves),
        Exercise(name: "Seated Calf Raise", muscleGroup: .calves),
        Exercise(name: "Leg Press Calf Raise", muscleGroup: .calves),
        Exercise(name: "Donkey Calf Raise", muscleGroup: .calves),

        // MARK: - ABS / CORE
        Exercise(name: "Cable Crunch", muscleGroup: .absCore),
        Exercise(name: "Hanging Leg Raise", muscleGroup: .absCore),
        Exercise(name: "Knee Raise", muscleGroup: .absCore),
        Exercise(name: "Ab Wheel", muscleGroup: .absCore),
        Exercise(name: "Plank", muscleGroup: .absCore),
        Exercise(name: "Side Plank", muscleGroup: .absCore),
        Exercise(name: "Machine Crunch", muscleGroup: .absCore),
        Exercise(name: "Russian Twist", muscleGroup: .absCore),
        Exercise(name: "Decline Sit-Up", muscleGroup: .absCore),

        // MARK: - OTHER / FULL BODY
        Exercise(name: "Farmer's Walk", muscleGroup: .other),
        Exercise(name: "Kettlebell Swing", muscleGroup: .other),
        Exercise(name: "Clean", muscleGroup: .other),
        Exercise(name: "Power Clean", muscleGroup: .other),
        Exercise(name: "Snatch", muscleGroup: .other),
        Exercise(name: "Sled Push", muscleGroup: .other)
    ]
    
    public static func defaultTemplates(for exercises: [Exercise]) -> [WorkoutTemplate] {
        func ids(for names: [String]) -> [UUID] {
            names.compactMap { name in
                exercises.first(where: { $0.name.lowercased() == name.lowercased() })?.id
            }
        }
        
        return [
            WorkoutTemplate(
                name: "Push",
                notes: "Chest, Shoulders & Triceps focus",
                exerciseIds: ids(for: [
                    "Dumbbell Bench Press",
                    "Incline Dumbbell Press",
                    "Cable Chest Fly",
                    "Arnold Press",
                    "Dumbbell Lateral Raise",
                    "Triceps Pushdown"
                ])
            ),
            WorkoutTemplate(
                name: "Pull",
                notes: "Back, Rear Delts & Biceps focus",
                exerciseIds: ids(for: [
                    "Pull-Up",
                    "Lat Pulldown",
                    "Barbell Row",
                    "Face Pull",
                    "Barbell Curl",
                    "Hammer Curl"
                ])
            ),
            WorkoutTemplate(
                name: "Legs",
                notes: "Quads, Hamstrings & Calves focus",
                exerciseIds: ids(for: [
                    "Barbell Squat",
                    "Romanian Deadlift",
                    "Leg Press",
                    "Leg Curl",
                    "Standing Calf Raise"
                ])
            ),
            WorkoutTemplate(
                name: "Upper",
                notes: "Complete upper body routine",
                exerciseIds: ids(for: [
                    "Barbell Bench Press",
                    "Barbell Row",
                    "Barbell Overhead Press",
                    "Lat Pulldown",
                    "Dumbbell Curl",
                    "Skull Crushers"
                ])
            ),
            WorkoutTemplate(
                name: "Lower",
                notes: "Complete lower body routine",
                exerciseIds: ids(for: [
                    "Barbell Squat",
                    "Romanian Deadlift",
                    "Bulgarian Split Squat",
                    "Leg Extension",
                    "Seated Calf Raise"
                ])
            ),
            WorkoutTemplate(
                name: "Full Body",
                notes: "Compound movements for the entire body",
                exerciseIds: ids(for: [
                    "Barbell Squat",
                    "Barbell Bench Press",
                    "Pull-Up",
                    "Dumbbell Shoulder Press",
                    "Romanian Deadlift"
                ])
            )
        ]
    }
}
