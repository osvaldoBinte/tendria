import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' as dio;  // 👈 Alias para Dio
import 'package:signalr_netcore/signalr_client.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:get/get.dart' hide Response;  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat Tendria',
      theme: ThemeData(
        primaryColor: const Color(0xFF128C7E),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF128C7E),
          secondary: Color(0xFF25D366),
          error: Color(0xFFDC3545),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF128C7E),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF128C7E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// ============================================
// LOGGER
// ============================================
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void info(String message) => _logger.i(message);
  static void debug(String message) => _logger.d(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
  static void success(String message) => _logger.i('✅ $message');
}
// ============================================
// MODELS
// ============================================
class AuthResponseModel {
  final String token;
  final String? userId;
  final String? email;
  final String? nombre;

  AuthResponseModel({
    required this.token,
    this.userId,
    this.email,
    this.nombre,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      // 👇 Maneja tanto String como int
      userId: json['userId']?.toString(),
      email: json['email'] as String?,
      nombre: json['nombre'] as String?,
    );
  }
}

class MessageModel {
  final int? id;
  final int chatId;
  final String mensaje;
  final String? senderNombre;
  final bool esPropio;
  final DateTime? enviadoEn;

  MessageModel({
    this.id,
    required this.chatId,
    required this.mensaje,
    this.senderNombre,
    this.esPropio = false,
    this.enviadoEn,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      // 👇 Maneja conversión segura
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      chatId: json['chatId'] is int ? json['chatId'] : int.parse(json['chatId'].toString()),
      mensaje: json['mensaje'] as String,
      senderNombre: json['senderNombre'] as String?,
      esPropio: json['esPropio'] as bool? ?? false,
      enviadoEn: json['enviadoEn'] != null 
          ? DateTime.parse(json['enviadoEn']) 
          : null,
    );
  }
}

// ============================================
// API SERVICE
// ============================================
// ============================================
// API SERVICE
// ============================================
class ApiService {
  static const String baseUrl = 'https://api-tendria.grupogerena.com.mx';
  late final dio.Dio _dio;  // 👈 Usar alias
  String? _token;

  ApiService() {
    _dio = dio.Dio(dio.BaseOptions(  // 👈 Usar alias
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(  // 👈 Usar alias
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        AppLogger.debug('🌐 ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.success(
          '✅ ${response.requestOptions.method} ${response.requestOptions.path} - ${response.statusCode}'
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error(
          '❌ ${error.requestOptions.method} ${error.requestOptions.path}',
          error,
        );
        return handler.next(error);
      },
    ));
  }

  void setToken(String token) => _token = token;

  Future<dio.Response> post(String path, {dynamic data}) async {  // 👈 Usar alias
    return await _dio.post(path, data: data);
  }

  Future<dio.Response> get(String path) async {  // 👈 Usar alias
    return await _dio.get(path);
  }
}

// ============================================
// SIGNALR SERVICE
// ============================================
class SignalRService {
  HubConnection? _hubConnection;
  
  final Function(MessageModel)? onMessageReceived;
  final Function()? onReconnecting;
  final Function()? onReconnected;
  final Function()? onDisconnected;

  SignalRService({
    this.onMessageReceived,
    this.onReconnecting,
    this.onReconnected,
    this.onDisconnected,
  });

  bool get isConnected => 
      _hubConnection?.state == HubConnectionState.Connected;

 Future<void> connect(String token) async {
  int retryCount = 0;
  const maxRetries = 3;
  
  while (retryCount < maxRetries) {
    try {
      final hubUrl = '${ApiService.baseUrl}/api/chathub';
      
      AppLogger.info('🔌 Intento ${retryCount + 1}/$maxRetries - Creando conexión SignalR...');
      AppLogger.info('📍 URL del Hub: $hubUrl');
      
      // Si no es el primer intento, espera un poco
      if (retryCount > 0) {
        AppLogger.info('⏳ Esperando ${retryCount} segundos antes de reintentar...');
        await Future.delayed(Duration(seconds: retryCount));
      }
      
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                AppLogger.debug('🔑 Proveyendo token a SignalR...');
                return token;
              },
              transport: HttpTransportType.LongPolling,
              logMessageContent: true,
              requestTimeout: 100000,
            ),
          )
          .withAutomaticReconnect(retryDelays: [
            2000,
            5000,
            10000,
            30000,
          ])
          .build();

      // Event handlers
      _hubConnection!.onreconnecting(({error}) {
        AppLogger.warning('⚠️ Reconectando...');
        onReconnecting?.call();
      });

      _hubConnection!.onreconnected(({connectionId}) {
        AppLogger.success('✅ Reconectado! Connection ID: $connectionId');
        onReconnected?.call();
      });

      _hubConnection!.onclose(({error}) {
        AppLogger.error('❌ Conexión cerrada');
        if (error != null) {
          AppLogger.error('Detalle del error: $error');
        }
        onDisconnected?.call();
      });

      _hubConnection!.on('ReceiveMessage', (arguments) {
        try {
          AppLogger.debug('📨 Evento ReceiveMessage recibido');
          
          if (arguments != null && arguments.isNotEmpty) {
            final messageData = arguments[0] as Map<String, dynamic>;
            final message = MessageModel.fromJson(messageData);
            AppLogger.success('📥 Mensaje recibido de ${message.senderNombre}');
            onMessageReceived?.call(message);
          }
        } catch (e, stack) {
          AppLogger.error('❌ Error procesando mensaje', e, stack);
        }
      });

      AppLogger.info('🚀 Iniciando conexión SignalR...');
      
      await _hubConnection!.start();
      
      AppLogger.success('✅ Conectado exitosamente!');
      AppLogger.success('Connection ID: ${_hubConnection!.connectionId}');
      
      return;
      
    } catch (e, stack) {
      retryCount++;
      
      AppLogger.warning('⚠️ Intento ${retryCount} falló: $e');
      
      if (retryCount >= maxRetries) {
        AppLogger.error('❌ Error al conectar después de $maxRetries intentos');
        AppLogger.error('URL intentada: ${ApiService.baseUrl}/api/chathub');
        AppLogger.error('Tipo de error: ${e.runtimeType}');
        AppLogger.error('Mensaje: $e', e, stack);
        rethrow;
      }
      
      try {
        await _hubConnection?.stop();
        _hubConnection = null;
      } catch (_) {}
      
      AppLogger.info('🔄 Reintentando...');
    }
  }
}

  Future<void> joinChat(int chatId) async {
    if (!isConnected) {
      AppLogger.error('⚠️ No hay conexión activa');
      throw Exception('No hay conexión activa');
    }

    try {
      AppLogger.info('📍 Uniéndose al chat #$chatId...');
      AppLogger.debug('Estado de conexión: ${_hubConnection!.state}');
      AppLogger.debug('Connection ID: ${_hubConnection!.connectionId}');
      
      await _hubConnection!.invoke('JoinChat', args: [chatId]);
      
      AppLogger.success('✅ Unido al chat #$chatId');
    } catch (e, stack) {
      AppLogger.error('❌ Error al unirse al chat', e, stack);
      rethrow;
    }
  }

  Future<void> leaveChat(int chatId) async {
    if (!isConnected) return;

    try {
      AppLogger.info('👋 Saliendo del chat #$chatId...');
      await _hubConnection!.invoke('LeaveChat', args: [chatId]);
      AppLogger.success('✅ Salió del chat #$chatId');
    } catch (e, stack) {
      AppLogger.error('❌ Error al salir del chat', e, stack);
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        AppLogger.info('🔌 Cerrando conexión SignalR...');
        AppLogger.debug('Estado antes de cerrar: ${_hubConnection!.state}');
        
        await _hubConnection!.stop();
        
        AppLogger.success('✅ Desconectado correctamente');
      } catch (e, stack) {
        AppLogger.error('❌ Error al desconectar', e, stack);
      }
    }
  }

  void dispose() {
    _hubConnection?.off('ReceiveMessage');
    disconnect();
  }
}
// ============================================
// AUTH CONTROLLER
// ============================================
class AuthController extends GetxController {
  final _apiService = ApiService();
  final _storage = GetStorage();

  final Rx<AuthResponseModel?> _authResponse = Rx<AuthResponseModel?>(null);
  AuthResponseModel? get authResponse => _authResponse.value;
  String? get token => _authResponse.value?.token;
  bool get isAuthenticated => _authResponse.value != null;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedToken();
  }

  void _loadSavedToken() {
    final savedToken = _storage.read('auth_token');
    if (savedToken != null) {
      _authResponse.value = AuthResponseModel(token: savedToken);
      AppLogger.info('🔐 Token cargado desde storage');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      AppLogger.info('🔐 Intentando login con: $email');

      final response = await _apiService.post(
        '/api/Auth/login',
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      _authResponse.value = authResponse;
      _apiService.setToken(authResponse.token);
      
      await _storage.write('auth_token', authResponse.token);
      
      AppLogger.success('✅ Login exitoso!');
      Get.snackbar(
        '✅ Éxito',
        'Login exitoso!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e, stack) {
      AppLogger.error('❌ Error en login', e, stack);
      Get.snackbar(
        '❌ Error',
        'Error en login: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    _authResponse.value = null;
    await _storage.remove('auth_token');
    AppLogger.info('👋 Sesión cerrada');
  }
}

// ============================================
// CHAT CONTROLLER
// ============================================
class ChatController extends GetxController {
  final _apiService = ApiService();
  late final SignalRService _signalRService;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isConnected = false.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentChatId = 0.obs;
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initializeSignalR();
  }

  void _initializeSignalR() {
    _signalRService = SignalRService(
      onMessageReceived: (message) {
        messages.add(message);
        _scrollToBottom();
      },
      onReconnecting: () {
        isConnected.value = false;
        Get.snackbar(
          '⚠️ Reconectando...',
          '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      onReconnected: () {
        isConnected.value = true;
        Get.snackbar(
          '✅ Reconectado',
          '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
      onDisconnected: () {
        isConnected.value = false;
        Get.snackbar(
          '❌ Desconectado',
          '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> connectToChat(int chatId, String token) async {
    try {
      isLoading.value = true;
      currentChatId.value = chatId;

      // Configurar token en API service
      _apiService.setToken(token);

      // Conectar a SignalR
      await _signalRService.connect(token);
      
      // Unirse al chat específico
      await _signalRService.joinChat(chatId);
      
      isConnected.value = true;
      
      // Cargar mensajes anteriores
      await loadMessages();

      Get.snackbar(
        '✅ Conectado',
        'Unido al chat #$chatId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, stack) {
      AppLogger.error('❌ Error al conectar', e, stack);
      Get.snackbar(
        '❌ Error',
        'Error al conectar: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages() async {
    try {
      AppLogger.info('📜 Cargando mensajes del chat #${currentChatId.value}');
      
      final response = await _apiService.get(
        '/api/mensajes/chat/${currentChatId.value}',
      );
      
      final data = response.data;
      final loadedMessages = (data['mensajes'] as List)
          .map((m) => MessageModel.fromJson(m))
          .toList();
      
      messages.value = loadedMessages;
      
      AppLogger.success('✅ Cargados ${loadedMessages.length} mensajes');
      
      _scrollToBottom();
    } catch (e, stack) {
      AppLogger.error('❌ Error al cargar mensajes', e, stack);
      Get.snackbar(
        '❌ Error',
        'Error al cargar mensajes: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    
    if (messageText.isEmpty) return;

    if (!isConnected.value) {
      Get.snackbar(
        '❌ Error',
        'No estás conectado!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      AppLogger.info('📤 Enviando mensaje: "$messageText"');

      await _apiService.post(
        '/api/mensajes',
        data: {
          'chatId': currentChatId.value,
          'mensaje': messageText,
        },
      );
      
      messageController.clear();
      AppLogger.success('✅ Mensaje enviado');
    } catch (e, stack) {
      AppLogger.error('❌ Error al enviar', e, stack);
      Get.snackbar(
        '❌ Error',
        'Error al enviar: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> disconnect() async {
    try {
      if (currentChatId.value > 0) {
        await _signalRService.leaveChat(currentChatId.value);
      }
      await _signalRService.disconnect();
      
      isConnected.value = false;
      messages.clear();
      currentChatId.value = 0;
      
      Get.snackbar(
        '👋 Desconectado',
        'Desconectado del chat',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e, stack) {
      AppLogger.error('❌ Error al desconectar', e, stack);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearMessages() {
    messages.clear();
    AppLogger.info('🗑️ Mensajes limpiados');
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _signalRService.dispose();
    super.onClose();
  }
}

// ============================================
// LOGIN PAGE
// ============================================
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final authController = Get.put(AuthController());
  final emailController = TextEditingController(text: 'prueba@prueba.com');
  final passwordController = TextEditingController(text: 'Prueba123');
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Título
                  const Icon(
                    Icons.chat_bubble_rounded,
                    size: 80,
                    color: Color(0xFF128C7E),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🚀 Chat Tendria',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SignalR Test App',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Token Display
                  Obx(() {
                    if (authController.token != null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🎫 Token JWT:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              authController.token!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 24),

                  // Login Button
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authController.isLoading.value
                              ? null
                              : () => _handleLogin(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF128C7E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  '🔐 Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (formKey.currentState!.validate()) {
      final success = await authController.login(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        Get.off(() => ChatPage());
      }
    }
  }
}

// ============================================
// CHAT PAGE
// ============================================
class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final authController = Get.find<AuthController>();
  final chatController = Get.put(ChatController());
  final chatIdController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Chat Tendria'),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chatController.isConnected.value
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      chatController.isConnected.value
                          ? '✅ Conectado'
                          : '❌ Desconectado',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
                Get.back();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionPanel(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildConnectionPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: chatIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Chat ID',
                    prefixIcon: Icon(Icons.chat),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => ElevatedButton.icon(
                    onPressed: chatController.isLoading.value
                        ? null
                        : () => _connectToChat(),
                    icon: chatController.isLoading.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.power_settings_new),
                    label: Text(chatController.isConnected.value
                        ? 'Desconectar'
                        : 'Conectar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: chatController.isConnected.value
                          ? Colors.red
                          : const Color(0xFF128C7E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => chatController.clearMessages(),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Limpiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Obx(() {
      if (chatController.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay mensajes',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Conéctate a un chat para empezar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        color: const Color(0xFFFAFAFA),
        child: ListView.builder(
          controller: chatController.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: chatController.messages.length,
          itemBuilder: (context, index) {
            final message = chatController.messages[index];
            return _buildMessageBubble(message);
          },
        ),
      );
    });
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMyMessage = message.esPropio;
    final timeStr = message.enviadoEn != null
        ? DateFormat('HH:mm').format(message.enviadoEn!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMyMessage ? const Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMyMessage && message.senderNombre != null)
                Text(
                  message.senderNombre!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF128C7E),
                    fontSize: 13,
                  ),
                ),
              if (!isMyMessage && message.senderNombre != null)
                const SizedBox(height: 4),
              Text(
                message.mensaje,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: chatController.messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => chatController.sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF128C7E),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => chatController.sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connectToChat() {
    final chatId = int.tryParse(chatIdController.text);
    if (chatId == null) {
      Get.snackbar(
        '❌ Error',
        'Chat ID inválido',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (chatController.isConnected.value) {
      chatController.disconnect();
    } else {
      if (authController.token != null) {
        chatController.connectToChat(chatId, authController.token!);
      }
    }
  }
}