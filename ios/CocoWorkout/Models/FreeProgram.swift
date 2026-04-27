import Foundation

struct FreeExercise: Identifiable {
    let id: UUID
    let name: String

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

struct FreeWorkoutDay: Identifiable {
    let id: Int
    let label: String
    let exercises: [FreeExercise]
}

struct FreeProgram: Identifiable {
    let id: Int
    let name: String
    let days: [FreeWorkoutDay]
}

extension FreeProgram {
    static let svobodnaya = FreeProgram(
        id: 1,
        name: "Свободная",
        days: [
            FreeWorkoutDay(
                id: 1,
                label: "День 1 — Ноги",
                exercises: [
                    FreeExercise(name: "Ягодичный мост"),
                    FreeExercise(name: "Румынская тяга"),
                    FreeExercise(name: "Присед в колодец (на степах с гирей)"),
                    FreeExercise(name: "Болгарские выпады"),
                    FreeExercise(name: "Подъем на 1 ноге"),
                    FreeExercise(name: "Отведение ноги в кроссовере"),
                    FreeExercise(name: "Отведение ноги в кроссовере вбок"),
                    FreeExercise(name: "Гиперэкстензия"),
                ]
            ),
            FreeWorkoutDay(
                id: 2,
                label: "День 2 — Верх",
                exercises: [
                    FreeExercise(name: "Отжимания от колена"),
                    FreeExercise(name: "Подтягивания на гравитроне или с резинкой"),
                    FreeExercise(name: "Вертикальная тяга широким хватом"),
                    FreeExercise(name: "Горизонтальная тяга узким хватом"),
                    FreeExercise(name: "Полувер"),
                    FreeExercise(name: "Тяга каната на заднюю дельту"),
                    FreeExercise(name: "Подъем гантелей в наклоне бабочкой"),
                    FreeExercise(name: "Жим Арнольда"),
                    FreeExercise(name: "Отжимания от скамьи на трицепс"),
                    FreeExercise(name: "Подъёмы гантелей вперёд под 45 градусов"),
                ]
            ),
        ]
    )
}
