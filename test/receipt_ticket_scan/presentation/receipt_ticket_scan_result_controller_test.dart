import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipt_ticket_scan/presentation/receipt_ticket_scan_result_controller.dart';

void main() {
  const ingredients = <Ingredient>[
    Ingredient(
      name: "Tomato",
      quantity: "4",
      date: null,
    ),
    Ingredient(
      name: "Oignon",
      quantity: "5",
      date: null,
    ),
    Ingredient(
      name: "Salt",
      quantity: "3",
      date: null,
    ),
  ];
  const firstUpdatedIngredients = <Ingredient>[
    Ingredient(
      name: "Tomato",
      quantity: "4",
      date: null,
    ),
    Ingredient(
      name: "Oignon",
      quantity: "6",
      date: null,
    ),
    Ingredient(
      name: "Salt",
      quantity: "3",
      date: null,
    ),
  ];
  const secondUpdatedIngredients = <Ingredient>[
    Ingredient(
      name: "Tomato",
      quantity: "4",
      date: null,
    ),
    Ingredient(
      name: "Oignon",
      quantity: "6",
      date: null,
    ),
    Ingredient(
      name: "Salt",
      quantity: "2",
      date: null,
    ),
  ];

  ReceiptTicketScanResultController buildSut() {
    return ReceiptTicketScanResultController(
      ingredients: ingredients,
    );
  }

  blocTest<ReceiptTicketScanResultController, ReceiptTicketScanResultState>(
    'should be in initial state',
    build: () => buildSut(),
    verify: (bloc) {
      expect(bloc.state, ReceiptTicketScanResultInitial());
    },
  );

  blocTest<ReceiptTicketScanResultController, ReceiptTicketScanResultState>(
    'should update ingredient',
    build: () => buildSut(),
    act: (bloc) {
      bloc.updateIngredient(1, 6);
      bloc.updateIngredient(2, 2);
    },
    expect: () => [
      ReceiptTicketUpdateIngredientSuccess(
        ingredients: firstUpdatedIngredients,
      ),
      ReceiptTicketUpdateIngredientSuccess(
        ingredients: secondUpdatedIngredients,
      ),
    ],
  );
}
