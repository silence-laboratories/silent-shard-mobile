import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silentshard/demo/state_decorators/keyshares_provider.dart';

class WalletCreatedScreen extends StatelessWidget {
  const WalletCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 20,
                    color: const Color(0xFF4CBD87),
                  ),
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF4CBD87),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Your Wallet is created',
                style: (TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color(0xFFE27525),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.language,
                  color: Color(0xFFE27525),
                  size: 30,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Network',
                style: (TextStyle(
                  color: Color(0xFFB2C6FE),
                  // fontSize: 20,
                  // fontWeight: FontWeight.bold,
                )),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Sepolia Testnet',
                style: (TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color(0xFFE27525),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Color(0xFFE27525),
                  size: 30,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'S;lent Account',
                style: (TextStyle(
                  color: Color(0xFFB2C6FE),
                )),
              ),
              const SizedBox(
                height: 10,
              ),
              Consumer<KeysharesProvider>(
                  builder: (context, keysharesProvider, _) => SizedBox(
                        width: 250,
                        child: Text(
                          keysharesProvider.keyshares.firstOrNull?.ethAddress ?? "Unknown address",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5841F),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
