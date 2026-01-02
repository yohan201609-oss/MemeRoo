import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jigsaw_provider.dart';
import '../models/jigsaw_piece_model.dart';
import '../utils/colors.dart';
import 'jigsaw_victory_screen.dart';

class JigsawGameScreen extends StatefulWidget {
  const JigsawGameScreen({super.key});

  @override
  State<JigsawGameScreen> createState() => _JigsawGameScreenState();
}

class _JigsawGameScreenState extends State<JigsawGameScreen> {
  final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final provider = context.read<JigsawProvider>();
      provider.initializeGame(provider.currentLevel, size);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JigsawProvider>();

    // Navegación automática
    if (provider.gameState == JigsawGameState.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => JigsawVictoryScreen(
              seconds: provider.seconds,
              level: provider.currentLevel,
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, provider),
              Expanded(
                child: Stack(
                  key: _stackKey,
                  children: [
                    // Área de construcción (siluetas)
                    _buildBoardArea(provider),
                    // Piezas arrastrables (solo las que NO están colocadas)
                    ...provider.pieces.where((piece) => !piece.isPlaced).map((piece) {
                      return _buildDraggablePiece(piece, provider);
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, JigsawProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
            color: Colors.black87,
          ),
          Column(
            children: [
              Text(
                'Piezas: ${provider.piecesPlaced}/${provider.totalPieces}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                provider.getFormattedTime(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Botón para ver imagen completa
              IconButton(
                icon: const Icon(Icons.remove_red_eye, size: 24),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Imagen Completa'),
                      content: Container(
                        width: 200,
                        height: 200,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: provider.cols,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: provider.totalPieces,
                          itemBuilder: (context, index) {
                            final piece = provider.pieces.firstWhere(
                              (p) => p.correctRow == index ~/ provider.cols &&
                                     p.correctCol == index % provider.cols,
                            );
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Center(
                                child: Text(
                                  piece.partEmoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
                color: Colors.blue,
                tooltip: 'Ver imagen completa',
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 28),
                onPressed: () {
                  final size = MediaQuery.of(context).size;
                  provider.resetGame(size);
                },
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoardArea(JigsawProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardWidth = screenWidth * 0.8;
    final boardHeight = provider.pieceSize * provider.rows;
    final boardLeft = (screenWidth - boardWidth) / 2;
    final boardTop = 100.0;

    return Positioned(
      top: boardTop,
      left: boardLeft,
      child: Container(
        width: boardWidth,
        height: boardHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        child: GridView.builder(
          key: ValueKey('board_${provider.piecesPlaced}'), // Forzar reconstrucción cuando cambia el número de piezas colocadas
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: provider.cols,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: provider.totalPieces,
          itemBuilder: (context, index) {
            // Mostrar silueta gris o pieza colocada
            final piece = provider.pieces.firstWhere(
              (p) => p.correctRow == index ~/ provider.cols &&
                     p.correctCol == index % provider.cols,
            );

            if (piece.isPlaced) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Center(
                  child: Text(
                    piece.partEmoji,
                    style: TextStyle(fontSize: provider.pieceSize * 0.6),
                  ),
                ),
              );
            } else {
              // Silueta vacía con pista del emoji
              final targetPiece = provider.pieces.firstWhere(
                (p) => p.correctRow == index ~/ provider.cols &&
                       p.correctCol == index % provider.cols,
              );
              
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300.withOpacity(0.5),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.3, // Muy transparente como pista
                    child: Text(
                      targetPiece.partEmoji,
                      style: TextStyle(fontSize: provider.pieceSize * 0.4),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDraggablePiece(JigsawPiece piece, JigsawProvider provider) {
    if (piece.isPlaced) return const SizedBox();

    return Positioned(
      left: piece.currentPosition.dx,
      top: piece.currentPosition.dy,
      child: Draggable<int>(
        data: piece.id,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: provider.pieceSize,
            height: provider.pieceSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                piece.partEmoji,
                style: TextStyle(fontSize: provider.pieceSize * 0.6),
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: Container(
            width: provider.pieceSize,
            height: provider.pieceSize,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
        ),
        onDragEnd: (details) {
          // Convertir posición global a local del Stack
          final RenderBox? renderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final localPosition = renderBox.globalToLocal(details.offset);
            
            // Obtener la posición del tablero en coordenadas del Stack
            // El tablero está en un Positioned con top: 100, left: (screenWidth - boardWidth) / 2
            final screenWidth = MediaQuery.of(context).size.width;
            final boardWidth = screenWidth * 0.8;
            final boardLeft = (screenWidth - boardWidth) / 2;
            final boardTop = 100.0;
            
            // Convertir posición absoluta del tablero a coordenadas del Stack
            final boardGlobalPosition = Offset(boardLeft, boardTop);
            final stackBoardPosition = renderBox.globalToLocal(boardGlobalPosition);
            
            provider.onPieceDropped(piece.id, localPosition, stackBoardPosition);
          } else {
            // Fallback: usar la posición global directamente
            provider.onPieceDropped(piece.id, details.offset, Offset.zero);
          }
        },
        child: Container(
          width: provider.pieceSize,
          height: provider.pieceSize,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              piece.partEmoji,
              style: TextStyle(fontSize: provider.pieceSize * 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

