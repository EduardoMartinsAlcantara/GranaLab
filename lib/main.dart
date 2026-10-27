import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://djstjlswtwbqnezchizr.supabase.co',
    anonKey: 'sb_publishable_i1AtJkOgg7hPnl7RVMFj6g_bVRM7scR',
  );
  runApp(const GranaLabApp());
}

final supa = Supabase.instance.client;

String _brl(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

const kGreen = Color(0xFF1B5E20);
const kGreenLight = Color(0xFF43A047);
const kDark = Color(0xFF07140B);
const kBg = Color(0xFFF5F7FA);
const kText = Color(0xFF1F2937);
const kMuted = Color(0xFF6B7280);
const kRed = Color(0xFFE5484D);

class GranaLabApp extends StatelessWidget {
  const GranaLabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GranaLab',
        builder: (context, child) => ColoredBox(
          color: const Color(0xFF020805),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child,
            ),
          ),
        ),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: kGreen,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        home: const SplashPage(),
      );
}

// Título serifado em itálico (o "charme" do vídeo de referência)
TextStyle serif(double size) => GoogleFonts.playfairDisplay(
    fontSize: size,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w700,
    color: Colors.white);

Route<void> fade(Widget page) => PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
    );

// Entrada suave: sobe 12% e aparece, com atraso (stagger)
class Reveal extends StatefulWidget {
  final int delay;
  final Widget child;
  const Reveal({super.key, required this.delay, required this.child});
  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) c.forward();
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero)
            .animate(a),
        child: widget.child,
      ),
    );
  }
}

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 72});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .3),
          gradient: const LinearGradient(
              colors: [kGreenLight, kGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: const [
            BoxShadow(color: Color(0x6643A047), blurRadius: 30)
          ],
        ),
        child: Icon(Icons.savings_rounded, color: Colors.white, size: size * .5),
      );
}

// ---------------------------------------------------------------- SPLASH
const _g2 = Color(0xFF2E7D32);
const _g4 = Color(0xFF66BB6A);

double _backOut(double x) {
  x = x.clamp(0.0, 1.0).toDouble();
  const c1 = 1.70158, c3 = c1 + 1;
  return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const total = 3.4; // segundos
  late final AnimationController c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3400));

  @override
  void initState() {
    super.initState();
    c.addStatusListener((st) {
      if (st == AnimationStatus.completed && mounted) {
        final logado = supa.auth.currentSession != null;
        Navigator.of(context).pushReplacement(
            fade(logado ? const HomePage() : const AuthPage()));
      }
    });
    c.forward();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kDark,
        body: AnimatedBuilder(
          animation: c,
          builder: (_, __) {
            final t = c.value * total;
            final ta = ((t - 2.3) / 0.6).clamp(0.0, 1.0).toDouble();
            final e = 1 - math.pow(1 - ta, 3).toDouble();
            return Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _PiggyPainter(t))),
              Align(
                alignment: const Alignment(0, 0.4),
                child: Opacity(
                  opacity: e,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - e)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text.rich(TextSpan(
                          text: 'Grana',
                          style: serif(36),
                          children: [
                            TextSpan(
                                text: 'Lab',
                                style: serif(36).copyWith(color: kGreenLight)),
                          ])),
                      const SizedBox(height: 8),
                      const Text('Dinheiro se aprende na prática',
                          style: TextStyle(color: Color(0xFF9CA3AF))),
                    ]),
                  ),
                ),
              ),
            ]);
          },
        ),
      );
}

class _PiggyPainter extends CustomPainter {
  final double t; // segundos desde o início
  _PiggyPainter(this.t);

  static const starts = [0.4, 0.75, 1.1, 1.45];
  static const offs = [-90.0, 70.0, -50.0, 100.0];
  static const fall = 0.55;

  double _cl(double v) => v.clamp(0.0, 1.0).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width * 0.62 / 520;
    final ax = size.width / 2, ay = size.height * 0.56;
    final r = size.width * 0.058;
    final slotY0 = ay + (126 - 540) * s;
    final y0 = -r * 1.5, yEnd = slotY0 + r + 14;
    final u0 = math.sqrt((slotY0 - y0) / (yEnd - y0));
    final lands = [for (final st in starts) st + u0 * fall];

    // brilho verde ao fundo
    final glowC = Offset(ax, ay - 120 * s);
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(colors: const [
            Color(0x661B5E20),
            Color(0x001B5E20)
          ]).createShader(Rect.fromCircle(center: glowC, radius: size.width * 0.6)));

    // pop de entrada e "amassadinha" a cada moeda
    final pop = t < 0.5 ? 0.35 + 0.65 * _backOut(t / 0.5) : 1.0;
    double a = 0;
    for (final tl in lands) {
      final dt = t - tl;
      if (dt >= 0 && dt < 0.4) {
        a += 0.075 * math.exp(-dt * 9) * math.cos(dt * 26);
      }
    }
    final jMax = 70 * size.width / 1080;
    final jt = lands.last + 0.3;
    final ju = _cl((t - jt) / 0.45);
    final jump = (ju > 0 && ju < 1) ? jMax * math.sin(math.pi * ju) : 0.0;
    if (ju >= 1) {
      final dt = t - (jt + 0.45);
      a += 0.09 * math.exp(-dt * 10) * math.cos(dt * 26);
    }
    final sy = (1 - a) * pop, sx = (1 + a * 0.6) * pop;

    // sombra no chão
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(ax, ay + 10 * s),
            width: 600 * s * pop,
            height: 36 * s),
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, 0.45 * (1 - 0.5 * _cl(jump / jMax)))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    canvas.save();
    canvas.translate(ax, ay - jump);
    canvas.scale(s * sx, s * sy);
    canvas.translate(-380, -540);
    _bank(canvas);
    canvas.restore();

    // moedas: somem ao passar pela fenda
    final slotX = ax + (370 - 380) * s * sx;
    final slotY = ay - jump + (126 - 540) * s * sy;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, slotY));
    for (var i = 0; i < starts.length; i++) {
      final u = (t - starts[i]) / fall;
      if (u < 0 || u > 1.05) continue;
      final y = y0 + (yEnd - y0) * u * u;
      final x = slotX +
          offs[i] * size.width / 1080 * math.pow(1 - _cl(u), 1.3).toDouble();
      _coin(canvas, Offset(x, y), r, u * 3.4 * math.pi + i);
    }
    canvas.restore();
  }

  void _coin(Canvas c, Offset o, double r, double phase) {
    final cw = math.cos(phase).abs();
    final w = cw < 0.14 ? 0.14 : cw;
    c.save();
    c.translate(o.dx, o.dy);
    final edge = r * (0.26 * (1 - w) + 0.1);
    c.drawOval(
        Rect.fromCenter(
            center: Offset.zero, width: 2 * r * w + edge, height: 2 * r),
        Paint()..color = const Color(0xFFB8860B));
    c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 2 * r * w, height: 2 * r),
        Paint()..color = const Color(0xFFF5B301));
    if (r * w > 6) {
      c.drawOval(
          Rect.fromCenter(
              center: Offset.zero, width: 2 * r * w * 0.78, height: 2 * r * 0.78),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.09
            ..color = const Color(0xFFFFD54F));
    }
    if (cw > 0.55) {
      final tp = TextPainter(
        text: TextSpan(
            text: '\$',
            style: TextStyle(
                color: const Color(0xFFB8860B),
                fontSize: r * 1.25,
                fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
    }
    c.restore();
  }

  // Cofrinho desenhado em coordenadas locais (760 x 560, pés em y = 540)
  void _bank(Canvas c) {
    Paint f(Color col) => Paint()
      ..isAntiAlias = true
      ..color = col;
    for (final x in [215.0, 445.0]) {
      c.drawRRect(
          RRect.fromLTRBR(x, 430, x + 85, 545, const Radius.circular(28)),
          f(_g2));
    }
    c.drawPath(
        Path()
          ..moveTo(455, 150)
          ..lineTo(505, 52)
          ..lineTo(585, 160)
          ..close(),
        f(_g2));
    c.drawPath(
        Path()
          ..moveTo(480, 145)
          ..lineTo(510, 92)
          ..lineTo(560, 152)
          ..close(),
        f(_g4));
    c.drawArc(
        const Rect.fromLTRB(55, 245, 155, 345),
        1.4,
        4.36,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..color = _g2);
    c.drawOval(const Rect.fromLTRB(120, 110, 640, 490), f(_g2));
    c.drawOval(const Rect.fromLTRB(120, 110, 640, 455), f(kGreenLight));
    c.drawOval(
        const Rect.fromLTRB(190, 140, 420, 260),
        Paint()
          ..color = const Color(0x5566BB6A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    c.drawOval(const Rect.fromLTRB(605, 245, 715, 385), f(_g2));
    c.drawOval(const Rect.fromLTRB(612, 252, 700, 376), f(kGreenLight));
    const nose = Color(0xFF0B1A10);
    c.drawOval(const Rect.fromLTRB(650, 288, 666, 320), f(nose));
    c.drawOval(const Rect.fromLTRB(650, 326, 666, 358), f(nose));
    c.drawOval(const Rect.fromLTRB(488, 216, 526, 254), f(nose));
    c.drawOval(const Rect.fromLTRB(502, 222, 512, 232), f(Colors.white));
    c.drawOval(const Rect.fromLTRB(300, 112, 440, 140), f(kDark));
  }

  @override
  bool shouldRepaint(_PiggyPainter old) => old.t != t;
}

// ------------------------------------------------------------------ AUTH
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  bool signUp = false, hide = true, student = true, loading = false;
  String? erro;
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  String _traduz(String m) {
    final t = m.toLowerCase();
    if (t.contains('already')) return 'Este e-mail já está cadastrado.';
    if (t.contains('invalid login')) return 'E-mail ou senha incorretos.';
    if (t.contains('rate limit')) return 'Muitas tentativas. Aguarde um pouco.';
    return m;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      loading = true;
      erro = null;
    });
    try {
      if (signUp) {
        final res = await supa.auth.signUp(
          email: _email.text.trim(),
          password: _senha.text,
          data: {
            'nome': _nome.text.trim(),
            'papel': student ? 'aluno' : 'professor',
          },
        );
        if (res.session == null) {
          setState(() => erro = 'Conta criada! Confirme o e-mail para entrar.');
          return;
        }
      } else {
        await supa.auth.signInWithPassword(
            email: _email.text.trim(), password: _senha.text);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fade(const HomePage()));
    } on AuthException catch (e) {
      setState(() => erro = _traduz(e.message));
    } catch (_) {
      setState(() => erro = 'Sem conexão. Tente de novo.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) {
    OutlineInputBorder b(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color));
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: kMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: kBg,
      border: b(Colors.transparent),
      enabledBorder: b(Colors.transparent),
      focusedBorder: b(kGreen),
      errorBorder: b(kRed),
      focusedErrorBorder: b(kRed),
      errorStyle: const TextStyle(color: kRed, fontSize: 12),
    );
  }

  Widget _tab(String label, bool active, bool toSignUp) => Expanded(
        child: GestureDetector(
          onTap: () {
            _form.currentState?.reset();
            setState(() {
              signUp = toSignUp;
              erro = null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? kDark : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : kMuted)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sheet = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _form,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: kBg, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              _tab('Entrar', !signUp, false),
              _tab('Criar conta', signUp, true),
            ]),
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: signUp
                ? Column(children: [
                    TextFormField(
                      controller: _nome,
                      decoration: _dec('Nome', Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Digite seu nome.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      ChoiceChip(
                          label: const Text('Aluno'),
                          selected: student,
                          onSelected: (_) => setState(() => student = true)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                          label: const Text('Professor'),
                          selected: !student,
                          onSelected: (_) => setState(() => student = false)),
                    ]),
                    const SizedBox(height: 12),
                  ])
                : const SizedBox(width: double.infinity),
          ),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _dec('E-mail', Icons.mail_outline),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Digite um e-mail válido.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _senha,
            obscureText: hide,
            decoration: _dec('Senha', Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                      hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: kMuted),
                  onPressed: () => setState(() => hide = !hide),
                )),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Mínimo de 6 caracteres.' : null,
          ),
          if (erro != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kRed, fontSize: 13)),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(signUp ? 'Criar conta' : 'Entrar',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Protótipo: sem dinheiro real, só saldo fictício.',
              style: TextStyle(color: kMuted, fontSize: 12)),
        ]),
      ),
    );

    return Scaffold(
      backgroundColor: kDark,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Column(children: [
                  const SizedBox(height: 40),
                  const Logo(size: 56),
                  const SizedBox(height: 20),
                  Text(signUp ? 'Crie sua conta.' : 'Bem-vindo de volta.',
                      style: serif(32)),
                  const SizedBox(height: 8),
                  const Text('Aprenda a lidar com dinheiro jogando.',
                      style: TextStyle(color: Color(0xFF9CA3AF))),
                  const Spacer(),
                  Reveal(delay: 200, child: sheet),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ HOME
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int nav = 0;
  String nome = 'Aluno', papel = 'aluno';
  double saldo = 500;
  List<Map<String, dynamic>> trans = [], aulas = [];
  Set<int> feitas = {};

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    final u = supa.auth.currentUser;
    if (u == null) return;
    try {
      final p = await supa.from('profiles').select().eq('id', u.id).single();
      if (!mounted) return;
      setState(() {
        nome = p['nome'] as String;
        papel = p['papel'] as String;
        saldo = (p['saldo'] as num).toDouble();
      });
    } catch (_) {}
    try {
      final t = await supa
          .from('transacoes')
          .select()
          .order('criado_em', ascending: false)
          .limit(100);
      final a = await supa.from('aulas').select().order('id');
      final g = await supa.from('progresso').select().eq('concluida', true);
      if (!mounted) return;
      setState(() {
        trans = List<Map<String, dynamic>>.from(t);
        aulas = List<Map<String, dynamic>>.from(a);
        feitas = {for (final x in g) x['aula_id'] as int};
      });
    } catch (_) {}
  }

  Future<void> _sair() async {
    await supa.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fade(const AuthPage()));
  }

  Widget _card(Widget child) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: child,
      );

  Widget _titulo(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t,
            style: const TextStyle(
                color: kText, fontSize: 17, fontWeight: FontWeight.w800)),
      );

  Widget _gastos() {
    final porCat = <String, double>{};
    for (final m in trans.where((m) => m['tipo'] == 'gasto')) {
      final c = m['categoria'] as String;
      porCat[c] = (porCat[c] ?? 0) + (m['valor'] as num).toDouble();
    }
    final total = porCat.values.fold(0.0, (a, b) => a + b);
    final lista = porCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _titulo('Para onde foi seu dinheiro'),
      if (lista.isEmpty)
        Row(children: [
          const Expanded(
            child: Text('Você ainda não registrou gastos.',
                style: TextStyle(color: kMuted)),
          ),
          TextButton(
              onPressed: () => setState(() => nav = 1),
              child: const Text('Registrar')),
        ])
      else ...[
        Text('Total gasto: ${_brl(total)}',
            style: const TextStyle(color: kMuted, fontSize: 13)),
        const SizedBox(height: 12),
        for (final e in lista.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: Text(e.key,
                        style: const TextStyle(
                            color: kText, fontWeight: FontWeight.w600))),
                Text(_brl(e.value),
                    style: const TextStyle(color: kMuted, fontSize: 13)),
              ]),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: e.value / total),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  color: kGreen,
                  backgroundColor: kBg,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ]),
          ),
      ],
    ]));
  }

  Widget _continuar() {
    if (aulas.isEmpty) return const SizedBox.shrink();
    final prox = aulas.firstWhere((a) => !feitas.contains(a['id']),
        orElse: () => <String, dynamic>{});
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _titulo(prox.isEmpty ? 'Aulas concluídas' : 'Continue aprendendo'),
      if (prox.isEmpty)
        const Text('Parabéns! Você concluiu todas as aulas disponíveis.',
            style: TextStyle(color: kMuted))
      else ...[
        Text(prox['titulo'] as String,
            style: const TextStyle(
                color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 2),
        Text(prox['resumo'] as String,
            style: const TextStyle(color: kMuted, fontSize: 13)),
        const SizedBox(height: 10),
        Text('${feitas.length} de ${aulas.length} aulas concluídas',
            style: const TextStyle(
                color: kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              await Navigator.of(context)
                  .push(fade(LessonPage(aula: prox, feita: false)));
              _carrega();
            },
            child: const Text('Abrir aula (+R\$ 25,00)'),
          ),
        ),
      ],
    ]));
  }

  Widget _ultimas() {
    if (trans.isEmpty) return const SizedBox.shrink();
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _titulo('Últimas movimentações')),
        TextButton(
            onPressed: () => setState(() => nav = 1),
            child: const Text('Ver tudo')),
      ]),
      for (final m in trans.take(3))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(
                m['tipo'] == 'gasto'
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: m['tipo'] == 'gasto' ? kRed : kGreen,
                size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(m['descricao'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kText))),
            Text(
                '${m['tipo'] == 'gasto' ? '-' : '+'}${_brl((m['valor'] as num).toDouble())}',
                style: TextStyle(
                    color: m['tipo'] == 'gasto' ? kRed : kGreen,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
    ]));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kDark,
        bottomNavigationBar: NavigationBar(
          selectedIndex: nav,
          onDestinationSelected: (i) {
            setState(() => nav = i);
            if (i == 0) _carrega();
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFDCEFDD),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Início'),
            NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                label: 'Carteira'),
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined), label: 'Aulas'),
            NavigationDestination(
                icon: Icon(Icons.trending_up_rounded), label: 'Investir'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
        body: nav == 1
            ? const CarteiraTab()
            : nav == 2
                ? const AulasTab()
                : nav == 3
                    ? const InvestirTab()
                    : SafeArea(
                    bottom: false,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Row(children: [
                          const CircleAvatar(
                              radius: 22,
                              backgroundColor: kGreen,
                              child: Icon(Icons.person, color: Colors.white)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Olá, $nome',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16)),
                                  Text(
                                      papel == 'professor'
                                          ? 'Professor'
                                          : 'Aluno',
                                      style: const TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 12)),
                                ]),
                          ),
                          IconButton(
                              onPressed: _sair,
                              tooltip: 'Sair',
                              icon: const Icon(Icons.logout_rounded,
                                  color: Colors.white)),
                        ]),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: Text('Seu resumo', style: serif(28)),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: sheetDeco,
                          child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                Reveal(
                                  delay: 100,
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: const LinearGradient(
                                          colors: [kGreenLight, kGreen],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0x401B5E20),
                                            blurRadius: 24,
                                            offset: Offset(0, 10))
                                      ],
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Saldo virtual',
                                              style: TextStyle(
                                                  color: Color(0xCCFFFFFF))),
                                          const SizedBox(height: 6),
                                          Text(_brl(saldo),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.w800)),
                                        ]),
                                  ),
                                ),
                                Reveal(delay: 200, child: _gastos()),
                                Reveal(delay: 300, child: _continuar()),
                                Reveal(delay: 400, child: _ultimas()),
                              ]),
                        ),
                      ),
                    ]),
                  ),
      );
}

// ------------------------------------------------------------- CARTEIRA
const categorias = ['Alimentação', 'Transporte', 'Lazer', 'Estudos', 'Outros'];

InputDecoration campo(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: kBg,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );

class CarteiraTab extends StatefulWidget {
  const CarteiraTab({super.key});
  @override
  State<CarteiraTab> createState() => _CarteiraTabState();
}

class _CarteiraTabState extends State<CarteiraTab> {
  List<Map<String, dynamic>> itens = [];
  double saldo = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    try {
      final u = supa.auth.currentUser!;
      final p =
          await supa.from('profiles').select('saldo').eq('id', u.id).single();
      final t = await supa
          .from('transacoes')
          .select()
          .order('criado_em', ascending: false)
          .limit(30);
      if (!mounted) return;
      setState(() {
        saldo = (p['saldo'] as num).toDouble();
        itens = List<Map<String, dynamic>>.from(t);
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _novo() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const NovaTransacao(),
    );
    if (ok == true) _carrega();
  }

  Future<void> _excluir(Map<String, dynamic> m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover movimentação?'),
        content: Text('"${m['descricao']}" será removida e o saldo ajustado.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remover')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await supa.rpc('excluir_transacao', params: {'p_id': m['id']});
      _carrega();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget _linha(Map<String, dynamic> m) {
    final gasto = m['tipo'] == 'gasto';
    final v = (m['valor'] as num).toDouble();
    final d = DateTime.parse(m['criado_em'] as String).toLocal();
    final data =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        CircleAvatar(
          backgroundColor:
              gasto ? const Color(0xFFFDE8E8) : const Color(0xFFDCEFDD),
          child: Icon(
              gasto ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: gasto ? kRed : kGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['descricao'] as String,
                style: const TextStyle(
                    color: kText, fontWeight: FontWeight.w700)),
            Text('${m['categoria']} · $data',
                style: const TextStyle(color: kMuted, fontSize: 12)),
          ]),
        ),
        Text('${gasto ? '-' : '+'}${_brl(v)}',
            style: TextStyle(
                color: gasto ? kRed : kGreen, fontWeight: FontWeight.w700)),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Remover',
          onPressed: () => _excluir(m),
          icon: const Icon(Icons.delete_outline_rounded, color: kMuted, size: 20),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text('Sua carteira', style: serif(28)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(_brl(saldo),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: kGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _novo,
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar movimentação'),
                    ),
                  ),
                ),
                Expanded(
                  child: carregando
                      ? const Center(child: CircularProgressIndicator())
                      : itens.isEmpty
                          ? const Center(
                              child: Text('Nenhuma movimentação ainda.',
                                  style: TextStyle(color: kMuted)))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: itens.length,
                              itemBuilder: (_, i) => _linha(itens[i]),
                            ),
                ),
              ]),
            ),
          ),
        ]),
      );
}

class NovaTransacao extends StatefulWidget {
  const NovaTransacao({super.key});
  @override
  State<NovaTransacao> createState() => _NovaTransacaoState();
}

class _NovaTransacaoState extends State<NovaTransacao> {
  String tipo = 'gasto', categoria = categorias.first;
  final _valor = TextEditingController();
  final _desc = TextEditingController();
  String? erro;
  bool loading = false;

  @override
  void dispose() {
    _valor.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final v = double.tryParse(_valor.text.trim().replaceAll(',', '.'));
    if (v == null || v <= 0) {
      setState(() => erro = 'Digite um valor maior que zero.');
      return;
    }
    if (_desc.text.trim().isEmpty) {
      setState(() => erro = 'Digite uma descrição.');
      return;
    }
    setState(() {
      loading = true;
      erro = null;
    });
    try {
      await supa.rpc('registrar_transacao', params: {
        'p_tipo': tipo,
        'p_valor': v,
        'p_descricao': _desc.text.trim(),
        'p_categoria': categoria,
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      setState(() => erro = e.message);
    } catch (_) {
      setState(() => erro = 'Sem conexão. Tente de novo.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ChoiceChip(
                    label: const Text('Gasto'),
                    selected: tipo == 'gasto',
                    onSelected: (_) => setState(() => tipo = 'gasto')),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Ganho'),
                    selected: tipo == 'ganho',
                    onSelected: (_) => setState(() => tipo = 'ganho')),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: _valor,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: campo('Valor (ex: 25,90)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _desc, decoration: campo('Descrição')),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: [
                for (final c in categorias)
                  ChoiceChip(
                      label: Text(c),
                      selected: categoria == c,
                      onSelected: (_) => setState(() => categoria = c)),
              ]),
              if (erro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(erro!,
                      style: const TextStyle(color: kRed, fontSize: 13)),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: loading ? null : _salvar,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Salvar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
      );
}


// ----------------------------------------------------------------- AULAS
Widget sheetTop(String titulo, {String? sub}) => Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Text(titulo, style: serif(28)),
        ),
      ),
      if (sub != null)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(sub, style: const TextStyle(color: Color(0xFF9CA3AF))),
          ),
        ),
    ]);

const sheetDeco = BoxDecoration(
  color: kBg,
  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
);

class AulasTab extends StatefulWidget {
  const AulasTab({super.key});
  @override
  State<AulasTab> createState() => _AulasTabState();
}

class _AulasTabState extends State<AulasTab> {
  List<Map<String, dynamic>> aulas = [];
  Map<int, Map<String, dynamic>> prog = {};
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    try {
      final a = await supa.from('aulas').select().order('id');
      final p = await supa.from('progresso').select();
      if (!mounted) return;
      setState(() {
        aulas = List<Map<String, dynamic>>.from(a);
        prog = {
          for (final x in p) x['aula_id'] as int: Map<String, dynamic>.from(x)
        };
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _abrir(Map<String, dynamic> aula) async {
    final feita = prog[aula['id']]?['concluida'] == true;
    await Navigator.of(context).push(fade(LessonPage(aula: aula, feita: feita)));
    _carrega();
  }

  @override
  Widget build(BuildContext context) {
    final feitas = prog.values.where((p) => p['concluida'] == true).length;
    return SafeArea(
      bottom: false,
      child: Column(children: [
        sheetTop('Aulas', sub: '$feitas de ${aulas.length} concluídas'),
        Expanded(
          child: Container(
            decoration: sheetDeco,
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView(padding: const EdgeInsets.all(20), children: [
                    for (var i = 0; i < aulas.length; i++)
                      Reveal(
                        key: ValueKey(aulas[i]['id']),
                        delay: 100 + i * 100,
                        child: _card(aulas[i]),
                      ),
                  ]),
          ),
        ),
      ]),
    );
  }

  Widget _card(Map<String, dynamic> a) {
    final p = prog[a['id']];
    final feita = p?['concluida'] == true;
    return GestureDetector(
      onTap: () => _abrir(a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: const Color(0xFFDCEFDD),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(feita ? Icons.check_circle_rounded : Icons.menu_book_outlined,
                color: kGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a['titulo'] as String,
                  style: const TextStyle(
                      color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(a['resumo'] as String,
                  style: const TextStyle(color: kMuted, fontSize: 12)),
              if (p != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Melhor resultado: ${p['acertos']}/${p['total']}',
                      style: const TextStyle(
                          color: kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: kMuted),
        ]),
      ),
    );
  }
}

class LessonPage extends StatelessWidget {
  final Map<String, dynamic> aula;
  final bool feita;
  const LessonPage({super.key, required this.aula, required this.feita});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kDark,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            sheetTop(aula['titulo'] as String, sub: aula['categoria'] as String),
            Expanded(
              child: Container(
                decoration: sheetDeco,
                child: Column(children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Text(aula['conteudo'] as String,
                          style: const TextStyle(
                              color: kText, fontSize: 16, height: 1.6)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, 8, 20, 20 + MediaQuery.of(context).padding.bottom),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.of(context)
                            .pushReplacement(fade(QuizPage(aula: aula, feita: feita))),
                        child: Text(
                            feita ? 'Refazer o quiz' : 'Fazer o quiz (+R\$ 25,00)',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> aula;
  final bool feita;
  const QuizPage({super.key, required this.aula, required this.feita});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> perguntas = [];
  int i = 0, acertos = 0, certas = 0;
  int? sel;
  bool carregando = true, enviando = false, fim = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    try {
      final q = await supa
          .from('perguntas')
          .select()
          .eq('aula_id', widget.aula['id'])
          .order('ordem');
      if (!mounted) return;
      setState(() {
        perguntas = List<Map<String, dynamic>>.from(q);
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  void _responder(int k) {
    if (sel != null) return;
    setState(() {
      sel = k;
      if (k == perguntas[i]['correta']) certas++;
    });
  }

  Future<void> _proxima() async {
    if (i < perguntas.length - 1) {
      setState(() {
        i++;
        sel = null;
      });
      return;
    }
    setState(() {
      enviando = true;
      erro = null;
    });
    try {
      final r = await supa.rpc('concluir_aula',
          params: {'p_aula': widget.aula['id'], 'p_acertos': certas});
      if (!mounted) return;
      setState(() {
        acertos = r as int;
        fim = true;
      });
    } on PostgrestException catch (e) {
      setState(() => erro = e.message);
    } catch (_) {
      setState(() => erro = 'Sem conexão. Tente de novo.');
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  Widget _opcao(String texto, int k, int correta) {
    var bg = Colors.white;
    var bd = Colors.transparent;
    if (sel != null) {
      if (k == correta) {
        bg = const Color(0xFFDCEFDD);
        bd = kGreen;
      } else if (k == sel) {
        bg = const Color(0xFFFDE8E8);
        bd = kRed;
      }
    }
    return GestureDetector(
      onTap: () => _responder(k),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bd, width: 1.5)),
        child: Text(texto,
            style: const TextStyle(
                color: kText, fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }

  Widget _corpo() {
    if (carregando) return const Center(child: CircularProgressIndicator());
    if (perguntas.isEmpty) {
      return const Center(child: Text('Sem perguntas nesta aula.'));
    }
    if (fim) {
      final ok = acertos * 100 >= perguntas.length * 60;
      final msg = ok
          ? (widget.feita
              ? 'Aula concluída. Sem novo prêmio, pois você já tinha concluído.'
              : 'Aula concluída! Você ganhou R\$ 25,00 de saldo virtual.')
          : 'Você precisa de pelo menos 60% para concluir. Releia a aula e tente de novo!';
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ok ? Icons.emoji_events_rounded : Icons.refresh_rounded,
              size: 72, color: ok ? const Color(0xFFF5B301) : kMuted),
          const SizedBox(height: 16),
          Text('Você acertou $acertos de ${perguntas.length}',
              style: const TextStyle(
                  color: kText, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kMuted, fontSize: 15)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar às aulas'),
            ),
          ),
        ]),
      );
    }
    final q = perguntas[i];
    final ops = List<String>.from(q['opcoes']);
    final correta = q['correta'] as int;
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text(q['pergunta'] as String,
          style: const TextStyle(
              color: kText, fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      for (var k = 0; k < ops.length; k++) _opcao(ops[k], k, correta),
      if (sel != null) ...[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Text(q['explicacao'] as String,
              style: const TextStyle(color: kMuted, height: 1.4)),
        ),
        if (erro != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(erro!, style: const TextStyle(color: kRed)),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: enviando ? null : _proxima,
            child: Text(i < perguntas.length - 1 ? 'Próxima' : 'Ver resultado'),
          ),
        ),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kDark,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              Expanded(
                child: Text(
                    fim || perguntas.isEmpty
                        ? 'Quiz'
                        : 'Pergunta ${i + 1} de ${perguntas.length}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 12),
            Expanded(child: Container(decoration: sheetDeco, child: _corpo())),
          ]),
        ),
      );
}


// ----------------------------------------------------------- INVESTIMENTOS
const produtos = [
  ('Poupança', 0.006, 'Baixo risco e rende pouco. Bom para começar.'),
  ('CDB', 0.009, 'Você empresta ao banco e ele paga mais que a poupança.'),
  ('Tesouro Selic', 0.010, 'Título do governo, seguro e com boa rentabilidade.'),
];

double _valorAtual(double v, double taxa, DateTime desde) {
  final min = DateTime.now().difference(desde).inMilliseconds / 60000;
  return v * math.pow(1 + taxa, math.min(math.max(min, 0.0), 120.0)).toDouble();
}

class InvestirTab extends StatefulWidget {
  const InvestirTab({super.key});
  @override
  State<InvestirTab> createState() => _InvestirTabState();
}

class _InvestirTabState extends State<InvestirTab> {
  List<Map<String, dynamic>> itens = [];
  double saldo = 0;
  bool carregando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carrega();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carrega() async {
    try {
      final u = supa.auth.currentUser!;
      final p =
          await supa.from('profiles').select('saldo').eq('id', u.id).single();
      final t = await supa
          .from('investimentos')
          .select()
          .filter('resgatado_em', 'is', null)
          .order('criado_em', ascending: false);
      if (!mounted) return;
      setState(() {
        saldo = (p['saldo'] as num).toDouble();
        itens = List<Map<String, dynamic>>.from(t);
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _aplicar(String produto) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => NovaAplicacao(produto: produto, saldo: saldo),
    );
    if (ok == true) _carrega();
  }

  Future<void> _resgatar(Map<String, dynamic> m) async {
    try {
      final v = await supa.rpc('resgatar', params: {'p_id': m['id']});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resgate de ${_brl((v as num).toDouble())} feito!')));
      _carrega();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget _titulo(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 6),
        child: Text(t,
            style: const TextStyle(
                color: kText, fontSize: 17, fontWeight: FontWeight.w800)),
      );

  BoxDecoration get _cardDeco => BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(20));

  Widget _produto((String, double, String) p) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.$1,
                  style: const TextStyle(
                      color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(p.$3, style: const TextStyle(color: kMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Text('${(p.$2 * 100).toStringAsFixed(1).replaceAll('.', ',')}% ao mês',
                  style: const TextStyle(
                      color: kGreen, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kGreen),
            onPressed: () => _aplicar(p.$1),
            child: const Text('Aplicar'),
          ),
        ]),
      );

  Widget _aplicacao(Map<String, dynamic> m) {
    final v = (m['valor'] as num).toDouble();
    final atual = _valorAtual(v, (m['taxa'] as num).toDouble(),
        DateTime.parse(m['criado_em'] as String));
    final lucro = atual - v;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco,
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['produto'] as String,
                style: const TextStyle(
                    color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
            Text('Aplicado: ${_brl(v)}',
                style: const TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text(_brl(atual),
                style: const TextStyle(
                    color: kText, fontWeight: FontWeight.w800, fontSize: 18)),
            Text('+${_brl(lucro)} de rendimento',
                style: const TextStyle(
                    color: kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
        OutlinedButton(
            onPressed: () => _resgatar(m), child: const Text('Resgatar')),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    var investido = 0.0, atual = 0.0;
    for (final m in itens) {
      final v = (m['valor'] as num).toDouble();
      investido += v;
      atual += _valorAtual(v, (m['taxa'] as num).toDouble(),
          DateTime.parse(m['criado_em'] as String));
    }
    return SafeArea(
      bottom: false,
      child: Column(children: [
        sheetTop('Investimentos', sub: 'Simulação: 1 minuto = 1 mês'),
        Expanded(
          child: Container(
            decoration: sheetDeco,
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView(padding: const EdgeInsets.all(20), children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                            colors: [kGreenLight, kGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total investido agora',
                                style: TextStyle(color: Color(0xCCFFFFFF))),
                            const SizedBox(height: 6),
                            Text(_brl(atual),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800)),
                            Text(
                                'Rendimento: +${_brl(atual - investido)}  ·  Saldo livre: ${_brl(saldo)}',
                                style: const TextStyle(
                                    color: Color(0xCCFFFFFF), fontSize: 12)),
                          ]),
                    ),
                    _titulo('Onde investir'),
                    for (final p in produtos) _produto(p),
                    _titulo('Minhas aplicações'),
                    if (itens.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Você ainda não aplicou nada.',
                            style: TextStyle(color: kMuted)),
                      )
                    else
                      for (final m in itens) _aplicacao(m),
                  ]),
          ),
        ),
      ]),
    );
  }
}

class NovaAplicacao extends StatefulWidget {
  final String produto;
  final double saldo;
  const NovaAplicacao({super.key, required this.produto, required this.saldo});
  @override
  State<NovaAplicacao> createState() => _NovaAplicacaoState();
}

class _NovaAplicacaoState extends State<NovaAplicacao> {
  final _valor = TextEditingController();
  String? erro;
  bool loading = false;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final v = double.tryParse(_valor.text.trim().replaceAll(',', '.'));
    if (v == null || v <= 0) {
      setState(() => erro = 'Digite um valor maior que zero.');
      return;
    }
    if (v > widget.saldo) {
      setState(() => erro = 'Saldo insuficiente.');
      return;
    }
    setState(() {
      loading = true;
      erro = null;
    });
    try {
      await supa.rpc('aplicar',
          params: {'p_produto': widget.produto, 'p_valor': v});
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      setState(() => erro = e.message);
    } catch (_) {
      setState(() => erro = 'Sem conexão. Tente de novo.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aplicar em ${widget.produto}',
                  style: const TextStyle(
                      color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Saldo disponível: ${_brl(widget.saldo)}',
                  style: const TextStyle(color: kMuted)),
              const SizedBox(height: 16),
              TextField(
                controller: _valor,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: campo('Valor (ex: 100,00)'),
              ),
              if (erro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(erro!,
                      style: const TextStyle(color: kRed, fontSize: 13)),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: loading ? null : _salvar,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmar aplicação',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
      );
}