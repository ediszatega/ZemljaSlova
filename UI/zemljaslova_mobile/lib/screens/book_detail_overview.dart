import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/cart_item.dart';
import '../providers/book_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite_provider.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/image_display_widget.dart';
import '../utils/snackbar_util.dart';
import '../utils/authorization.dart';
import 'book_availability.dart';
import '../services/book_rental_service.dart';
import '../services/api_service.dart';

class BookDetailOverviewScreen extends StatefulWidget {
  final Book book;
  
  const BookDetailOverviewScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailOverviewScreen> createState() => _BookDetailOverviewScreenState();
}

class _BookDetailOverviewScreenState extends State<BookDetailOverviewScreen> {
  late Future<Book?> _bookFuture;
  late BookRentalService _bookRentalService;
  bool _isCheckingAvailability = false;
  bool _canReserve = false;
  int? _reservationPosition;
  int? _reservationId;
  
  @override
  void initState() {
    super.initState();
    // Load fresh book data to ensure we have the latest info including author
    _loadBookData();
    // Load favourites for the current user
    _loadFavouriteStatus();
    _bookRentalService = BookRentalService(Provider.of<ApiService>(context, listen: false));
    if (widget.book.bookPurpose == BookPurpose.rent) {
      _loadExistingReservationAndPosition();
    }
  }
  
  void _loadBookData() {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    _bookFuture = bookProvider.getBookById(widget.book.id);
  }
  
  void _loadFavouriteStatus() {
    if (Authorization.userId != null) {
      final favouriteProvider = Provider.of<FavouriteProvider>(context, listen: false);
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      
      memberProvider.getMemberByUserId(Authorization.userId!).then((success) {
        if (success && memberProvider.currentMember != null) {
          favouriteProvider.fetchFavourites(memberProvider.currentMember!.id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const TopBranding(),
          Expanded(
            child: FutureBuilder<Book?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final book = snapshot.data ?? widget.book;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover and basic info
                _buildBookHeader(book),
                
                const SizedBox(height: 8),

                // Action buttons
                _buildActionButtons(book),

                const SizedBox(height: 30),
                
                // Book details section
                _buildBookDetailsSection(book),
                
                const SizedBox(height: 24),
                
                // Description section
                _buildDescriptionSection(book.description ?? ''),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      ),
      const BottomNavigation(),
        ],
      ),
    );
  }
  
  Widget _buildBookHeader(Book book) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: 400,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: ImageDisplayWidget.book(
                  imageUrl: book.coverImageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<FavouriteProvider>(
                  builder: (context, favouriteProvider, child) {
                    final isFavourite = favouriteProvider.isFavourite(book.id);
                    
                    return GestureDetector(
                      onTap: () async {
                        final memberProvider = Provider.of<MemberProvider>(context, listen: false);
                        if (memberProvider.currentMember != null) {
                          await favouriteProvider.toggleFavourite(memberProvider.currentMember!.id, book.id);
                          
                          if (mounted) {
                            final isNowFavourite = favouriteProvider.isFavourite(book.id);
                            SnackBarUtil.showTopSnackBar(
                              context,
                              isNowFavourite 
                                ? 'Knjiga je dodana u favourite!'
                                : 'Knjiga je uklonjena iz favorita!',
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                          color: isFavourite ? Colors.red : Colors.grey,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (book.bookPurpose != BookPurpose.rent && book.price != null) 
                  Text(
                    '${book.price!.toStringAsFixed(2)} KM',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookDetailsSection(Book book) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalji o knjizi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Detail rows
          _DetailRow(label: 'Autor', value: book.authorNames),
          if (book.genre != null && book.genre!.isNotEmpty)
            _DetailRow(label: 'Žanr', value: book.genre!),
          if (book.dateOfPublish != null && book.dateOfPublish!.isNotEmpty)
            _DetailRow(label: 'Godina izdavanja', value: book.dateOfPublish!),
          _DetailRow(label: 'Broj stranica', value: book.numberOfPages.toString()),
          if (book.weight != null)
            _DetailRow(label: 'Težina', value: '${book.weight!.toStringAsFixed(0)}g'),
          if (book.dimensions != null && book.dimensions!.isNotEmpty)
            _DetailRow(label: 'Dimenzije', value: book.dimensions!),
          if (book.binding != null && book.binding!.isNotEmpty)
            _DetailRow(label: 'Uvez', value: book.binding!),
          if (book.language != null && book.language!.isNotEmpty)
            _DetailRow(label: 'Jezik', value: book.language!),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionSection(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kratak opis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ExpandableDescription(description: description),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(Book book) {
    final isRentBook = book.bookPurpose == BookPurpose.rent;
    
    return Column(
        children: [
          if (!isRentBook) ...[
            if (book.quantityInStock > 0) ...[
              ZSButton(
                text: 'Dodaj u korpu',
                backgroundColor: const Color(0xFF28A745),
                foregroundColor: Colors.white,
                borderColor: const Color(0xFF28A745),
                onPressed: () {
                  _addBookToCart(book);
                },
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Knjiga nije na stanju',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ] else ...[
            ZSButton(
              text: 'Provjeri dostupnost',
              backgroundColor: const Color(0xFF007BFF),
              foregroundColor: Colors.white,
              borderColor: const Color(0xFF007BFF),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookAvailabilityScreen(
                      bookId: book.id,
                      bookTitle: book.title,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            if (_canReserve)
              ZSButton(
                text: _isCheckingAvailability ? 'Provjera...' : 'Rezerviši knjigu',
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                borderColor: Colors.orange,
                onPressed: _isCheckingAvailability ? null : () => _reserveBook(book),
              ),
                         if (_reservationPosition != null) ...[
               const SizedBox(height: 8),
               Text(
                 'Rezervisali ste ovu knjigu. Vaša pozicija u redu: $_reservationPosition',
                 style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
               ),
               const SizedBox(height: 8),
               ZSButton(
                 text: 'Otkaži rezervaciju',
                 backgroundColor: Colors.red,
                 foregroundColor: Colors.white,
                 borderColor: Colors.red,
                 onPressed: () => _cancelReservation(book),
               ),
             ],
          ],
        ],
      );
  }

  Future<void> _reserveBook(Book book) async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    if (memberProvider.currentMember == null) {
      SnackBarUtil.showTopSnackBar(context, 'Morate biti prijavljeni kao član.');
      return;
    }
    
    // Check if member has active membership
    final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    final hasActiveMembership = await membershipProvider.getActiveMembership(memberProvider.currentMember!.id);
    
    if (!hasActiveMembership || !membershipProvider.hasActiveMembership) {
      SnackBarUtil.showTopSnackBar(context, 'Morate imati aktivnu članarinu da biste mogli rezervirati knjige za iznajmljivanje.');
      return;
    }
    
    // Show confirmation dialog
     final shouldReserve = await showDialog<bool>(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text('Rezerviši knjigu'),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: const [
               Text(
                 'Trenutno su sve kopije ove knjige već iznajmljene, te vaša rezervacija vas stavlja na listu čekanja za iznajmljivanje ove knjige po povratku na stanje.',
               ),
               SizedBox(height: 8),
               Text(
                 'Kada rezervišete knjigu bit će vam prikazan broj na kojoj ste poziciji na listi čekanja.',
               ),
               SizedBox(height: 8),
               Text(
                 'Sama rezervacija vam daje prednost za iznajmljivanje knjige, ali ne i potpunu sigurnost, u slučaju da niste u mogućnosti da lično preuzmete knjigu u razumnom roku nakon što ona ponovo bude na stanju',
                 style: TextStyle(fontWeight: FontWeight.bold),
               ),
             ],
           ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Odustani'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text('Rezerviši'),
            ),
          ],
        );
      },
    );
    
    // If user cancelled the dialog, return early
    if (shouldReserve != true) {
      return;
    }
    
    setState(() { _isCheckingAvailability = true; });
    try {
      final res = await _bookRentalService.reserveBook(
        memberId: memberProvider.currentMember!.id,
        bookId: book.id,
      );
      if (res != null) {
        _reservationId = res['id'] as int?;
        if (_reservationId != null) {
          final pos = await _bookRentalService.getReservationPosition(_reservationId!);
          setState(() { 
            _reservationPosition = pos;
            _canReserve = false;
          });
          if (mounted) {
            SnackBarUtil.showTopSnackBar(context, 'Knjiga je rezervisana.');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showTopSnackBar(context, 'Rezervacija nije uspjela.');
      }
    } finally {
      setState(() { _isCheckingAvailability = false; });
    }
  }

  Future<void> _cancelReservation(Book book) async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    if (memberProvider.currentMember == null) {
      SnackBarUtil.showTopSnackBar(context, 'Morate biti prijavljeni kao član.');
      return;
    }
    
    if (_reservationId == null) {
      SnackBarUtil.showTopSnackBar(context, 'Nema aktivne rezervacije za otkazivanje.');
      return;
    }
    
    // Show confirmation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Otkaži rezervaciju'),
          content: const Text(
            'Jeste li sigurni da želite otkazati rezervaciju ove knjige? U slučaju otkazivanja gubite svoju poziciju na listi čekanja, te ponovnom rezervacijom bivate stavljeni na posljednju poziciju',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Odustani'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Otkaži'),
            ),
          ],
        );
      },
    );
    
    // If user cancelled the dialog, return early
    if (shouldCancel != true) {
      return;
    }
    
    setState(() { _isCheckingAvailability = true; });
    try {
      final success = await _bookRentalService.cancelReservation(
        _reservationId!,
        memberProvider.currentMember!.id,
      );
      
      if (success) {
        setState(() { 
          _reservationPosition = null;
          _reservationId = null;
        });
        // Recheck availability after cancellation
        await _loadExistingReservationAndPosition();
        if (mounted) {
          SnackBarUtil.showTopSnackBar(context, 'Rezervacija je otkazana.');
        }
      } else {
        if (mounted) {
          SnackBarUtil.showTopSnackBar(context, 'Otkazivanje rezervacije nije uspjelo.');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showTopSnackBar(context, 'Greška pri otkazivanju rezervacije.');
      }
    } finally {
      setState(() { _isCheckingAvailability = false; });
    }
  }

    Future<void> _loadExistingReservationAndPosition() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    if (memberProvider.currentMember == null) {
      return;
    }
    
    setState(() { _isCheckingAvailability = true; });
    
    try {
      final queue = await _bookRentalService.getBookQueue(widget.book.id);
      final idx = queue.indexWhere((e) => (e['memberId'] as int?) == memberProvider.currentMember!.id);
      
      if (idx >= 0) {
        // User has a reservation
        final userReservation = queue[idx];
        _reservationId = userReservation['id'] as int?;
        setState(() {
          _reservationPosition = idx + 1;
          _canReserve = false;
        });
      } else {
        // User doesn't have a reservation, check availability
        final physical = await _bookRentalService.getPhysicalStock(widget.book.id);
        final rented = await _bookRentalService.getCurrentlyRented(widget.book.id);
        final available = physical - rented;
        
        // Only show reserve button if there are physical copies and all are rented out
        final shouldShowReserveButton = physical > 0 && available <= 0;
        
        setState(() { _canReserve = shouldShowReserveButton; });
      }
    } catch (e) {
      // If we can't load the queue, don't show reserve button to be safe
      setState(() {
        _canReserve = false;
      });
    } finally {
      setState(() { _isCheckingAvailability = false; });
    }
  }

  void _addBookToCart(Book book) {
    if (book.bookPurpose == BookPurpose.rent || book.price == null) {
      SnackBarUtil.showTopSnackBar(context, 'Knjige za iznajmljivanje se ne mogu dodati u korpu!');
      return;
    }
    
    if (book.quantityInStock <= 0) {
      SnackBarUtil.showTopSnackBar(context, 'Knjiga nije na stanju!');
      return;
    }
    
    final cartItemId = 'book_${book.id}';
    
    final cartItem = CartItem(
      id: cartItemId,
      title: book.title,
      price: book.price!,
      quantity: 1,
      type: CartItemType.book,
    );

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(cartItem);

    SnackBarUtil.showTopSnackBar(context, 'Knjiga je dodana u korpu! Da biste završili kupovinu otvorite korpu.');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String description;
  
  const _ExpandableDescription({
    required this.description,
  });
  
  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded || widget.description.length <= 100
              ? widget.description 
              : '${widget.description.substring(0, 100)}...',
          style: const TextStyle(fontSize: 14),
        ),
        if (widget.description.length > 100)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Prikaži manje' : 'Prikaži više',
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
} 