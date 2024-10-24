import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuscaCepPage extends StatefulWidget {
  const BuscaCepPage({super.key});

  @override
  _BuscaCepPageState createState() => _BuscaCepPageState();
}

class _BuscaCepPageState extends State<BuscaCepPage> {
  final TextEditingController _cepController = TextEditingController();
  String? _logradouro;
  String? _bairro; 
  String? _cidade;
  String? _estado;
  double? _latitude;
  double? _longitude;
  bool _carregando = false;

  Future<void> _buscarCep() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty || cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um CEP válido')),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _logradouro = data['logradouro'];
          _bairro = data['bairro'];
          _cidade = data['localidade'];
          _estado = data['uf'];
          _latitude = -23.55052;  
          _longitude = -46.633308; 
        });
      } else {
        throw Exception('Erro ao buscar o CEP');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar o CEP: $e')),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca por CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              decoration: const InputDecoration(
                labelText: 'Digite o CEP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 8,
            ),// Exemplo fixo para São Paulo
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregando ? null : _buscarCep,
              child: _carregando ? const CircularProgressIndicator() : const Text('Buscar CEP'),
            ),
            const SizedBox(height: 16),
            if (_logradouro != null) ...[
              Text('Endereço: $_logradouro, $_bairro'),
              Text('Cidade: $_cidade, $_estado'),
            ],
            const SizedBox(height: 16),
            if (_latitude != null && _longitude != null)
              SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_latitude!, _longitude!),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('local'),
                      position: LatLng(_latitude!, _longitude!),
                    ),
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}