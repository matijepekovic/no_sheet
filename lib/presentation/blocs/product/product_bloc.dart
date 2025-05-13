// lib/presentation/blocs/product/product_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_event.dart';
import 'product_state.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../data/models/product.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  StreamSubscription<List<Product>>? _productsSubscription;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProduct>(_onLoadProduct);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
      LoadProducts event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductsLoading());
    try {
      await _productsSubscription?.cancel();
      _productsSubscription = _productRepository.getProducts().listen(
            (products) => add(ProductsLoaded(products) as ProductEvent),
        onError: (error) => add(ProductError(error.toString()) as ProductEvent),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProduct(
      LoadProduct event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductsLoading());
    try {
      final product = await _productRepository.getProduct(event.id);
      emit(ProductLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
      AddProduct event,
      Emitter<ProductState> emit,
      ) async {
    try {
      await _productRepository.addProduct(event.product);
      emit(const ProductOperationSuccess('Product added successfully'));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event,
      Emitter<ProductState> emit,
      ) async {
    try {
      await _productRepository.updateProduct(event.product);
      emit(const ProductOperationSuccess('Product updated successfully'));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event,
      Emitter<ProductState> emit,
      ) async {
    try {
      await _productRepository.deleteProduct(event.id);
      emit(const ProductOperationSuccess('Product deleted successfully'));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}