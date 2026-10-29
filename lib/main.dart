import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? turmaNome, erroTurma;
  final _cod = TextEditingController();

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
    try {
      final r = await supa.rpc('minha_turma');
      if (!mounted) return;
      setState(() => turmaNome = r as String?);
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

  Future<void> _entrar() async {
    try {
      final r = await supa
          .rpc('entrar_turma', params: {'p_codigo': _cod.text.trim()});
      if (!mounted) return;
      setState(() {
        turmaNome = r as String;
        erroTurma = null;
      });
    } on PostgrestException catch (e) {
      setState(() => erroTurma = e.message);
    }
  }

  Widget _turma() =>
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _titulo(turmaNome == null ? 'Entrar em uma turma' : 'Sua turma'),
        if (turmaNome != null)
          Text(turmaNome!,
              style: const TextStyle(
                  color: kGreen, fontWeight: FontWeight.w700, fontSize: 16))
        else ...[
          Row(children: [
            Expanded(
              child: TextField(
                controller: _cod,
                textCapitalization: TextCapitalization.characters,
                decoration: campo('Código do professor'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kGreen),
                onPressed: _entrar,
                child: const Text('Entrar')),
          ]),
          if (erroTurma != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(erroTurma!,
                  style: const TextStyle(color: kRed, fontSize: 13)),
            ),
        ],
      ]));

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
            child: Text('Abrir aula (+${_brl((prox['recompensa'] as num?)?.toDouble() ?? 25)})'),
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
                    : nav == 4
                        ? const PerfilTab()
                        : papel == 'professor'
                            ? const ProfessorTab()
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
                                Reveal(delay: 250, child: _turma()),
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
  bool carregando = true, professor = false;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    try {
      final a = await supa.from('aulas').select().order('id');
      final p = await supa.from('progresso').select();
      final me = await supa
          .from('profiles')
          .select('papel')
          .eq('id', supa.auth.currentUser!.id)
          .single();
      if (!mounted) return;
      setState(() {
        professor = me['papel'] == 'professor';
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

  Future<void> _criarAula() async {
    final ok = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const NovaAulaPage()));
    if (ok == true) _carrega();
  }

  Future<void> _excluir(Map<String, dynamic> a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir aula?'),
        content: Text('"${a['titulo']}" será removida para todos os alunos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await supa.rpc('excluir_aula', params: {'p_id': a['id']});
      _carrega();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
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
                    if (professor)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: kGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _criarAula,
                            icon: const Icon(Icons.add),
                            label: const Text('Criar aula'),
                          ),
                        ),
                      ),
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
              Text(
                  '${a['resumo']}  ·  +${_brl((a['recompensa'] as num?)?.toDouble() ?? 25)}',
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
          if (a['autor_id'] != null && a['autor_id'] == supa.auth.currentUser?.id)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Excluir',
              onPressed: () => _excluir(a),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: kMuted, size: 20),
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
                            feita ? 'Continuar' : 'Concluir aula (+${_brl((aula['recompensa'] as num?)?.toDouble() ?? 25)})',
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
  double get rec => (widget.aula['recompensa'] as num?)?.toDouble() ?? 25;
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

  Future<void> _concluirSemQuiz() async {
    setState(() {
      enviando = true;
      erro = null;
    });
    try {
      await supa.rpc('concluir_aula',
          params: {'p_aula': widget.aula['id'], 'p_acertos': 0});
      if (!mounted) return;
      setState(() {
        acertos = 0;
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
    if (perguntas.isEmpty && !fim) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.menu_book_rounded, size: 64, color: kGreen),
          const SizedBox(height: 16),
          const Text(
              'Esta aula não tem quiz. Quando terminar de ler, conclua para ganhar a recompensa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted, fontSize: 15)),
          if (erro != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(erro!, style: const TextStyle(color: kRed)),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: enviando ? null : _concluirSemQuiz,
              child: Text('Concluir aula (+${_brl(rec)})'),
            ),
          ),
        ]),
      );
    }
    if (fim) {
      final ok = acertos * 100 >= perguntas.length * 60;
      final msg = ok
          ? (widget.feita
              ? 'Aula concluída. Sem novo prêmio, pois você já tinha concluído.'
              : 'Aula concluída! Você ganhou ${_brl(rec)} de saldo virtual.')
          : 'Você precisa de pelo menos 60% para concluir. Releia a aula e tente de novo!';
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ok ? Icons.emoji_events_rounded : Icons.refresh_rounded,
              size: 72, color: ok ? const Color(0xFFF5B301) : kMuted),
          const SizedBox(height: 16),
          Text(perguntas.isEmpty ? 'Aula concluída!' : 'Você acertou $acertos de ${perguntas.length}',
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

const categoriasInv = ['Renda fixa', 'Ações', 'FIIs', 'Bitcoin'];
const _tiposInv = [null, 'acao', 'fii', 'cripto'];

String _pct(double v) =>
    '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2).replaceAll('.', ',')}%';

class InvestirTab extends StatefulWidget {
  const InvestirTab({super.key});
  @override
  State<InvestirTab> createState() => _InvestirTabState();
}

class _InvestirTabState extends State<InvestirTab> {
  List<Map<String, dynamic>> itens = [], ativos = [], posicoes = [];
  Map<String, double> preco = {};
  double saldo = 0;
  int cat = 0, tick = 0;
  bool carregando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carrega();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      tick++;
      if (tick % 5 == 0) _precos();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _precos() async {
    try {
      final r = await supa.rpc('listar_ativos');
      if (!mounted) return;
      final l = List<Map<String, dynamic>>.from(r);
      setState(() {
        ativos = l;
        preco = {
          for (final a in l) a['ticker'] as String: (a['preco'] as num).toDouble()
        };
      });
    } catch (_) {}
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
      final po = await supa
          .from('posicoes')
          .select()
          .filter('vendido_em', 'is', null)
          .order('criado_em', ascending: false);
      if (!mounted) return;
      setState(() {
        saldo = (p['saldo'] as num).toDouble();
        itens = List<Map<String, dynamic>>.from(t);
        posicoes = List<Map<String, dynamic>>.from(po);
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
    _precos();
  }

  Future<void> _abrirCompra(String nome, {String? ticker}) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => NovaAplicacao(produto: nome, ticker: ticker, saldo: saldo),
    );
    if (ok == true) _carrega();
  }

  Future<void> _abrirAtivo(Map<String, dynamic> a) async {
    final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => AtivoPage(ativo: a, saldo: saldo)));
    if (ok == true) _carrega();
  }

  Future<void> _sacar(String rpc, Map<String, dynamic> m, String verbo) async {
    try {
      final v = await supa.rpc(rpc, params: {'p_id': m['id']});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$verbo de ${_brl((v as num).toDouble())} feito!')));
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

  Widget _linhaCard(
          {required String titulo,
          required String sub,
          required String destaque,
          required Color corDestaque,
          required String botao,
          required VoidCallback onTap,
          bool contorno = false}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo,
                  style: const TextStyle(
                      color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(color: kMuted, fontSize: 12)),
              const SizedBox(height: 6),
              Text(destaque,
                  style: TextStyle(
                      color: corDestaque,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 12),
          contorno
              ? OutlinedButton(onPressed: onTap, child: Text(botao))
              : FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kGreen),
                  onPressed: onTap,
                  child: Text(botao)),
        ]),
      );

  Widget _produto((String, double, String) p) => _linhaCard(
        titulo: p.$1,
        sub: p.$3,
        destaque: '${(p.$2 * 100).toStringAsFixed(1).replaceAll('.', ',')}% ao mês',
        corDestaque: kGreen,
        botao: 'Aplicar',
        onTap: () => _abrirCompra(p.$1),
      );

  Widget _ativo(Map<String, dynamic> a) {
    final pr = (a['preco'] as num).toDouble();
    final v = (pr / (a['preco_base'] as num).toDouble() - 1) * 100;
    return GestureDetector(
      onTap: () => _abrirAtivo(a),
      child: _linhaCard(
      titulo: '${a['ticker']}  ·  ${_brl(pr)}',
      sub: a['nome'] as String,
      destaque: '${_pct(v)} vs. preço de referência',
      corDestaque: v >= 0 ? kGreen : kRed,
      botao: 'Comprar',
      onTap: () => _abrirCompra(a['nome'] as String, ticker: a['ticker'] as String),
    ));
  }

  Widget _aplicacao(Map<String, dynamic> m) {
    final v = (m['valor'] as num).toDouble();
    final atual = _valorAtual(v, (m['taxa'] as num).toDouble(),
        DateTime.parse(m['criado_em'] as String));
    return _linhaCard(
      titulo: m['produto'] as String,
      sub: 'Aplicado: ${_brl(v)}  ·  Agora: ${_brl(atual)}',
      destaque: '+${_brl(atual - v)} de rendimento',
      corDestaque: kGreen,
      botao: 'Resgatar',
      contorno: true,
      onTap: () => _sacar('resgatar', m, 'Resgate'),
    );
  }

  Widget _posicao(Map<String, dynamic> m) {
    final t = m['ticker'] as String;
    final v = (m['valor_investido'] as num).toDouble();
    final q = (m['quantidade'] as num).toDouble();
    final atual = q * (preco[t] ?? v / q);
    final lucro = atual - v;
    return _linhaCard(
      titulo: '$t  ·  ${q.toStringAsFixed(q < 1 ? 6 : 4)} un.',
      sub: 'Investido: ${_brl(v)}  ·  Agora: ${_brl(atual)}',
      destaque: '${lucro >= 0 ? '+' : '-'}${_brl(lucro.abs())} (${_pct(lucro / v * 100)})',
      corDestaque: lucro >= 0 ? kGreen : kRed,
      botao: 'Vender',
      contorno: true,
      onTap: () => _sacar('vender_ativo', m, 'Venda'),
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
    for (final m in posicoes) {
      final v = (m['valor_investido'] as num).toDouble();
      final q = (m['quantidade'] as num).toDouble();
      investido += v;
      atual += q * (preco[m['ticker'] as String] ?? v / q);
    }
    final lista = ativos.where((a) => a['tipo'] == _tiposInv[cat]).toList();
    return SafeArea(
      bottom: false,
      child: Column(children: [
        sheetTop('Investimentos', sub: 'Simulação com preços fictícios'),
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
                                'Resultado: ${atual >= investido ? '+' : '-'}${_brl((atual - investido).abs())}  ·  Saldo livre: ${_brl(saldo)}',
                                style: const TextStyle(
                                    color: Color(0xCCFFFFFF), fontSize: 12)),
                          ]),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoriasInv.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ChoiceChip(
                          label: Text(categoriasInv[i]),
                          selected: cat == i,
                          showCheckmark: false,
                          selectedColor: kDark,
                          labelStyle: TextStyle(
                              color: cat == i ? Colors.white : kText,
                              fontWeight: FontWeight.w600),
                          onSelected: (_) => setState(() => cat = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (cat == 0)
                      for (final p in produtos) _produto(p)
                    else if (lista.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Carregando preços...',
                            style: TextStyle(color: kMuted)),
                      )
                    else
                      for (final a in lista) _ativo(a),
                    _titulo('Minhas aplicações'),
                    if (itens.isEmpty && posicoes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Você ainda não aplicou nada.',
                            style: TextStyle(color: kMuted)),
                      )
                    else ...[
                      for (final m in itens) _aplicacao(m),
                      for (final m in posicoes) _posicao(m),
                    ],
                  ]),
          ),
        ),
      ]),
    );
  }
}

class NovaAplicacao extends StatefulWidget {
  final String produto;
  final String? ticker;
  final double saldo;
  const NovaAplicacao(
      {super.key, required this.produto, this.ticker, required this.saldo});
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
      if (widget.ticker != null) {
        await supa.rpc('comprar_ativo',
            params: {'p_ticker': widget.ticker, 'p_valor': v});
      } else {
        await supa.rpc('aplicar',
            params: {'p_produto': widget.produto, 'p_valor': v});
      }
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


// ---------------------------------------------------------------- PERFIL
class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});
  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  String nome = '', papel = 'aluno';
  double saldo = 0;
  int feitas = 0, totalAulas = 0, movs = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  String get nivel {
    if (totalAulas > 0 && feitas >= totalAulas) return 'Mestre das Finanças';
    if (feitas >= 2) return 'Investidor';
    if (feitas >= 1) return 'Poupador';
    return 'Aprendiz';
  }

  Future<void> _carrega() async {
    try {
      final u = supa.auth.currentUser!;
      final p = await supa.from('profiles').select().eq('id', u.id).single();
      final a = await supa.from('aulas').select('id');
      final g =
          await supa.from('progresso').select('aula_id').eq('concluida', true);
      final t = await supa.from('transacoes').select('id');
      if (!mounted) return;
      setState(() {
        nome = p['nome'] as String;
        papel = p['papel'] as String;
        saldo = (p['saldo'] as num).toDouble();
        totalAulas = a.length;
        feitas = g.length;
        movs = t.length;
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _editar() async {
    final c = TextEditingController(text: nome);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(controller: c, decoration: campo('Seu nome')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar')),
        ],
      ),
    );
    final novo = c.text.trim();
    if (ok != true || novo == nome) return;
    try {
      await supa.rpc('atualizar_nome', params: {'p_nome': novo});
      _carrega();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _sair() async {
    await supa.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fade(const AuthPage()));
  }

  Widget _info(IconData icon, String label, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(icon, color: kGreen, size: 22),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: kMuted, fontSize: 14))),
          Text(valor,
              style: const TextStyle(
                  color: kText, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final email = supa.auth.currentUser?.email ?? '';
    return SafeArea(
      bottom: false,
      child: Column(children: [
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 40,
          backgroundColor: kGreen,
          child: Text(nome.isEmpty ? '?' : nome[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        Text(nome, style: serif(28)),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(color: Color(0xFF9CA3AF))),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: sheetDeco,
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView(padding: const EdgeInsets.all(20), children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(children: [
                        _info(Icons.badge_outlined, 'Tipo de conta',
                            papel == 'professor' ? 'Professor' : 'Aluno'),
                        _info(Icons.workspace_premium_outlined, 'Nível', nivel),
                        _info(Icons.menu_book_outlined, 'Aulas concluídas',
                            '$feitas de $totalAulas'),
                        _info(Icons.receipt_long_outlined,
                            'Movimentações registradas', '$movs'),
                        _info(Icons.savings_outlined, 'Saldo virtual', _brl(saldo)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _editar,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar nome'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _sair,
                      icon: const Icon(Icons.logout_rounded, color: kRed),
                      label: const Text('Sair da conta',
                          style: TextStyle(color: kRed)),
                    ),
                  ]),
          ),
        ),
      ]),
    );
  }
}


// ------------------------------------------------------------- PROFESSOR
class ProfessorTab extends StatefulWidget {
  const ProfessorTab({super.key});
  @override
  State<ProfessorTab> createState() => _ProfessorTabState();
}

class _ProfessorTabState extends State<ProfessorTab> {
  List<Map<String, dynamic>> turmas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    try {
      final r = await supa.rpc('listar_turmas');
      if (!mounted) return;
      setState(() {
        turmas = List<Map<String, dynamic>>.from(r);
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _criar() async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova turma'),
        content: TextField(
            controller: c, decoration: campo('Nome (ex: 3º ano A)')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Criar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final cod = await supa.rpc('criar_turma', params: {'p_nome': c.text.trim()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Turma criada! Código: $cod')));
      _carrega();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Column(children: [
          sheetTop('Suas turmas', sub: 'Acompanhe o progresso dos alunos'),
          Expanded(
            child: Container(
              decoration: sheetDeco,
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(padding: const EdgeInsets.all(20), children: [
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: kGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _criar,
                          icon: const Icon(Icons.add),
                          label: const Text('Criar turma'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (turmas.isEmpty)
                        const Text(
                            'Você ainda não tem turmas. Crie uma e passe o código para os alunos.',
                            style: TextStyle(color: kMuted)),
                      for (final t in turmas)
                        GestureDetector(
                          onTap: () async {
                            await Navigator.of(context)
                                .push(fade(TurmaPage(turma: t)));
                            _carrega();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t['nome'] as String,
                                          style: const TextStyle(
                                              color: kText,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${t['alunos']} alunos  ·  Código: ${t['codigo']}',
                                          style: const TextStyle(
                                              color: kMuted, fontSize: 12)),
                                    ]),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: kMuted),
                            ]),
                          ),
                        ),
                    ]),
            ),
          ),
        ]),
      );
}

class TurmaPage extends StatefulWidget {
  final Map<String, dynamic> turma;
  const TurmaPage({super.key, required this.turma});
  @override
  State<TurmaPage> createState() => _TurmaPageState();
}

class _TurmaPageState extends State<TurmaPage> {
  List<Map<String, dynamic>> alunos = [];
  int totalAulas = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    try {
      final r = await supa
          .rpc('painel_turma', params: {'p_turma': widget.turma['id']});
      final a = await supa.from('aulas').select('id');
      if (!mounted) return;
      setState(() {
        alunos = List<Map<String, dynamic>>.from(r);
        totalAulas = a.length;
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codigo = widget.turma['codigo'] as String;
    final soma = alunos.fold<int>(
        0, (a, m) => a + (m['aulas_concluidas'] as num).toInt());
    final media = alunos.isEmpty ? 0.0 : soma / alunos.length;
    return Scaffold(
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
          sheetTop(widget.turma['nome'] as String, sub: 'Código da turma: $codigo'),
          Expanded(
            child: Container(
              decoration: sheetDeco,
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(padding: const EdgeInsets.all(20), children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                              '${alunos.length} alunos  ·  média de ${media.toStringAsFixed(1).replaceAll('.', ',')} aulas',
                              style: const TextStyle(
                                  color: kText, fontWeight: FontWeight.w700)),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: codigo));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Código copiado!')));
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copiar código'),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      if (alunos.isEmpty)
                        const Text(
                            'Nenhum aluno entrou ainda. Passe o código para a turma.',
                            style: TextStyle(color: kMuted)),
                      for (var i = 0; i < alunos.length; i++) _aluno(i, alunos[i]),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _aluno(int i, Map<String, dynamic> m) {
    final feitas = (m['aulas_concluidas'] as num).toInt();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFDCEFDD),
              child: Text('${i + 1}',
                  style: const TextStyle(
                      color: kGreen, fontWeight: FontWeight.w800, fontSize: 12))),
          const SizedBox(width: 10),
          Expanded(
              child: Text(m['nome'] as String,
                  style: const TextStyle(
                      color: kText, fontWeight: FontWeight.w700, fontSize: 15))),
          Text('$feitas/$totalAulas aulas',
              style: const TextStyle(
                  color: kGreen, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: totalAulas == 0 ? 0 : feitas / totalAulas,
          minHeight: 6,
          color: kGreen,
          backgroundColor: kBg,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 8),
        Text(
            'Saldo: ${_brl((m['saldo'] as num).toDouble())}  ·  Investido: ${_brl((m['investido'] as num).toDouble())}',
            style: const TextStyle(color: kMuted, fontSize: 12)),
      ]),
    );
  }
}


// ------------------------------------------------------------- NOVA AULA
class _Q {
  final texto = TextEditingController();
  final expl = TextEditingController();
  final ops = List.generate(4, (_) => TextEditingController());
  int correta = 0;
  void dispose() {
    texto.dispose();
    expl.dispose();
    for (final o in ops) {
      o.dispose();
    }
  }
}

class NovaAulaPage extends StatefulWidget {
  const NovaAulaPage({super.key});
  @override
  State<NovaAulaPage> createState() => _NovaAulaPageState();
}

class _NovaAulaPageState extends State<NovaAulaPage> {
  final _titulo = TextEditingController();
  final _resumo = TextEditingController();
  final _conteudo = TextEditingController();
  final _valor = TextEditingController(text: '25');
  String categoria = 'Poupar';
  final qs = <_Q>[];
  String? erro;
  bool loading = false;

  @override
  void dispose() {
    _titulo.dispose();
    _resumo.dispose();
    _conteudo.dispose();
    _valor.dispose();
    for (final q in qs) {
      q.dispose();
    }
    super.dispose();
  }

  Future<void> _publicar() async {
    final v = double.tryParse(_valor.text.trim().replaceAll(',', '.'));
    if (v == null || v < 0) {
      setState(() => erro = 'Digite uma recompensa válida (0 ou mais).');
      return;
    }
    final lista = <Map<String, dynamic>>[];
    for (var i = 0; i < qs.length; i++) {
      final q = qs[i];
      final ops = <String>[];
      int? certa;
      for (var k = 0; k < 4; k++) {
        final t = q.ops[k].text.trim();
        if (t.isEmpty) continue;
        if (k == q.correta) certa = ops.length;
        ops.add(t);
      }
      if (q.texto.text.trim().length < 3 || ops.length < 2 || certa == null) {
        setState(() => erro =
            'Pergunta ${i + 1}: escreva o enunciado, ao menos 2 opções e marque a correta.');
        return;
      }
      lista.add({
        'pergunta': q.texto.text.trim(),
        'opcoes': ops,
        'correta': certa,
        'explicacao': q.expl.text.trim(),
      });
    }
    setState(() {
      loading = true;
      erro = null;
    });
    try {
      await supa.rpc('criar_aula', params: {
        'p_titulo': _titulo.text,
        'p_categoria': categoria,
        'p_resumo': _resumo.text,
        'p_conteudo': _conteudo.text,
        'p_recompensa': v,
        'p_perguntas': lista,
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

  Widget _bloco(int i, _Q q) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('Pergunta ${i + 1}',
                  style: const TextStyle(
                      color: kText, fontWeight: FontWeight.w800)),
            ),
            IconButton(
              tooltip: 'Remover pergunta',
              onPressed: () => setState(() => qs.removeAt(i)),
              icon: const Icon(Icons.delete_outline_rounded, color: kMuted),
            ),
          ]),
          TextField(controller: q.texto, decoration: campo('Enunciado')),
          const SizedBox(height: 8),
          for (var k = 0; k < 4; k++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                IconButton(
                  onPressed: () => setState(() => q.correta = k),
                  icon: Icon(
                      q.correta == k
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: kGreen),
                ),
                Expanded(
                  child: TextField(
                      controller: q.ops[k],
                      decoration:
                          campo('Opção ${k + 1}${k < 2 ? '' : ' (opcional)'}')),
                ),
              ]),
            ),
          TextField(
              controller: q.expl,
              decoration: campo('Explicação da resposta (opcional)')),
        ]),
      );

  Widget _rotulo(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(t,
            style: const TextStyle(
                color: kText, fontWeight: FontWeight.w700, fontSize: 14)),
      );

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
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
            sheetTop('Nova aula', sub: 'Escreva o conteúdo e defina a recompensa'),
            Expanded(
              child: Container(
                decoration: sheetDeco,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    _rotulo('Título'),
                    TextField(controller: _titulo, decoration: campo('Ex: Como montar um orçamento')),
                    _rotulo('Categoria'),
                    Wrap(spacing: 8, children: [
                      for (final c in const ['Poupar', 'Investir', 'Gastos', 'Geral'])
                        ChoiceChip(
                            label: Text(c),
                            selected: categoria == c,
                            onSelected: (_) => setState(() => categoria = c)),
                    ]),
                    _rotulo('Resumo (opcional)'),
                    TextField(controller: _resumo, decoration: campo('Uma frase sobre a aula')),
                    _rotulo('Conteúdo da aula'),
                    TextField(
                      controller: _conteudo,
                      minLines: 8,
                      maxLines: 20,
                      keyboardType: TextInputType.multiline,
                      decoration: campo('Escreva o texto da aula aqui...'),
                    ),
                    _rotulo('Recompensa em R\$ (saldo virtual)'),
                    TextField(
                      controller: _valor,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: campo('Ex: 25'),
                    ),
                    _rotulo('Quiz (opcional)'),
                    const Text(
                        'Toque no círculo ao lado da opção correta. Sem perguntas, o aluno conclui a aula só lendo.',
                        style: TextStyle(color: kMuted, fontSize: 12)),
                    const SizedBox(height: 10),
                    for (var i = 0; i < qs.length; i++) _bloco(i, qs[i]),
                    if (qs.length < 10)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => qs.add(_Q())),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar pergunta'),
                      ),
                    if (erro != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(erro!,
                            style: const TextStyle(color: kRed, fontSize: 13)),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: loading ? null : _publicar,
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Publicar aula',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      );
}


// ---------------------------------------------------------------- GRÁFICO
class _LinhaPainter extends CustomPainter {
  final List<double> v;
  final Color cor, preenchimento;
  _LinhaPainter(this.v, this.cor, this.preenchimento);

  @override
  void paint(Canvas c, Size s) {
    if (v.length < 2) return;
    final mn = v.reduce(math.min), mx = v.reduce(math.max);
    final span = (mx - mn) == 0 ? 1.0 : (mx - mn);
    const pad = 10.0;
    Offset pt(int i) => Offset(i / (v.length - 1) * s.width,
        pad + (1 - (v[i] - mn) / span) * (s.height - 2 * pad));

    final grade = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (var k = 0; k < 4; k++) {
      final y = (k * (s.height - 1) / 3) + 0.5;
      c.drawLine(Offset(0, y), Offset(s.width, y), grade);
    }

    final linha = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < v.length; i++) {
      linha.lineTo(pt(i).dx, pt(i).dy);
    }
    final area = Path.from(linha)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    c.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [preenchimento, const Color(0x00FFFFFF)],
          ).createShader(Offset.zero & s));
    c.drawPath(
        linha,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = cor);
    final u = pt(v.length - 1);
    c.drawCircle(u, 7, Paint()..color = Colors.white);
    c.drawCircle(u, 5, Paint()..color = cor);
  }

  @override
  bool shouldRepaint(_LinhaPainter old) => true;
}

class AtivoPage extends StatefulWidget {
  final Map<String, dynamic> ativo;
  final double saldo;
  const AtivoPage({super.key, required this.ativo, required this.saldo});
  @override
  State<AtivoPage> createState() => _AtivoPageState();
}

class _AtivoPageState extends State<AtivoPage> {
  static const periodos = ['15 min', '1 hora', '6 horas', '24 horas'];
  static const minutos = [15, 60, 360, 1440];
  int per = 0;
  List<double> serie = [];
  bool carregando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carrega();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _carrega());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carrega() async {
    try {
      final r = await supa.rpc('historico_ativo', params: {
        'p_ticker': widget.ativo['ticker'],
        'p_minutos': minutos[per],
      });
      if (!mounted) return;
      setState(() {
        serie = [
          for (final x in List<Map<String, dynamic>>.from(r))
            (x['preco'] as num).toDouble()
        ];
        carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> _comprar() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => NovaAplicacao(
          produto: widget.ativo['nome'] as String,
          ticker: widget.ativo['ticker'] as String,
          saldo: widget.saldo),
    );
    if (ok == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final temDados = serie.length > 1;
    final atual = temDados ? serie.last : 0.0;
    final var_ = temDados ? (serie.last / serie.first - 1) * 100 : 0.0;
    final sobe = var_ >= 0;
    final cor = sobe ? kGreen : kRed;
    return Scaffold(
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
          sheetTop(widget.ativo['ticker'] as String,
              sub: widget.ativo['nome'] as String),
          Expanded(
            child: Container(
              decoration: sheetDeco,
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(padding: const EdgeInsets.all(20), children: [
                      Text(_brl(atual),
                          style: const TextStyle(
                              color: kText,
                              fontSize: 34,
                              fontWeight: FontWeight.w800)),
                      Text('${_pct(var_)} em ${periodos[per]}',
                          style: TextStyle(
                              color: cor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(height: 16),
                      Container(
                        height: 230,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        clipBehavior: Clip.antiAlias,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _LinhaPainter(
                              serie,
                              cor,
                              sobe
                                  ? const Color(0x4043A047)
                                  : const Color(0x40E5484D)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: periodos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ChoiceChip(
                            label: Text(periodos[i]),
                            selected: per == i,
                            showCheckmark: false,
                            selectedColor: kDark,
                            labelStyle: TextStyle(
                                color: per == i ? Colors.white : kText,
                                fontWeight: FontWeight.w600),
                            onSelected: (_) {
                              setState(() {
                                per = i;
                                carregando = true;
                              });
                              _carrega();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (temDados)
                        Row(children: [
                          Expanded(
                              child: _dado('Mínima', _brl(serie.reduce(math.min)))),
                          Expanded(
                              child: _dado('Máxima', _brl(serie.reduce(math.max)))),
                          Expanded(
                              child: _dado('Início', _brl(serie.first))),
                        ]),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: kGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _comprar,
                          child: Text('Comprar ${widget.ativo['ticker']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _dado(String rotulo, String valor) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(rotulo, style: const TextStyle(color: kMuted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(valor,
            style: const TextStyle(
                color: kText, fontWeight: FontWeight.w700, fontSize: 14)),
      ]);
}