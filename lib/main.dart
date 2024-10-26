import 'dart:convert'; // Para manejar JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa el paquete http

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clima Actual',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherPage(), // Pantalla principal
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  final _cityController = TextEditingController(); // Controlador del campo de texto
  final String _apiKey = '4dba1713865b68b1328408ceacf25204'; // Reemplaza con tu propia API key de OpenWeatherMap
  String _city = ''; // Ciudad a consultar
  String _temperature = ''; // Almacena la temperatura
  String _weatherDescription = ''; // Almacena la descripción del clima
  bool _isLoading = false; // Controla el estado de carga
  String _errorMessage = ''; // Mensaje de error para mostrar al usuario
  String _humidity = ''; // Almacena la humedad
  String _visibility = ''; // Almacena la visibilidad

  // Función para obtener el clima de la ciudad
  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Limpiar cualquier mensaje de error previo
    });

    // Remover espacios extra en el nombre de la ciudad
    _city = _city.trim();

    // Validar si el campo de ciudad está vacío
    if (_city.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Por favor, ingresa el nombre de una ciudad.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$_city&lang=es&appid=$_apiKey&units=metric'
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _temperature = jsonResponse['main']['temp'].toString();
          _weatherDescription = jsonResponse['weather'][0]['description'];
          _humidity = jsonResponse['main']['humidity'].toString();
          _visibility = jsonResponse['visibility'].toString();

          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'No se encontró la ciudad: $_city';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al obtener el clima. Intenta de nuevo.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Por favor, revisa tu internet.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clima Actual'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Campo de texto para ingresar la ciudad
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Ingresa una ciudad',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _city = value; // Actualiza la ciudad ingresada
              },
            ),
            SizedBox(height: 20),

            // Botón para consultar el clima
            ElevatedButton(
              onPressed: () {
                _fetchWeather(); // Llama a la API cuando se presiona el botón
              },
              child: Text('Obtener clima'),
            ),

            SizedBox(height: 20),

            // Muestra el estado de carga o los datos del clima
            _isLoading
                ? CircularProgressIndicator()
                : _errorMessage.isNotEmpty
                    ? Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      )
                    : Column(
                        children: [
                          if (_temperature.isNotEmpty) ...[
                            Text(
                              'Temperatura: $_temperature°C',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Descripción: $_weatherDescription',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Humedad: $_humidity%',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Visibilidad: $_visibility m',
                              style: TextStyle(fontSize: 18),
                            ),

                          ],
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}
