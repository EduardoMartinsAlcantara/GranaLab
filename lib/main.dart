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
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      final logado = supa.auth.currentSession != null;
      Navigator.of(context)
          .pushReplacement(fade(logado ? const HomePage() : const AuthPage()));
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kDark,
        body: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: c, curve: Curves.easeOutBack),
            child: FadeTransition(
              opacity: c,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Logo(size: 96),
                const SizedBox(height: 24),
                Text.rich(TextSpan(text: 'Grana', style: serif(36), children: [
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
      );
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
  int chip = 0, nav = 0;
  String nome = 'Aluno', papel = 'aluno';
  double saldo = 500;

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
  }

  Future<void> _sair() async {
    await supa.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fade(const AuthPage()));
  }
  static const chips = ['Todas', 'Poupar', 'Investir', 'Gastos'];
  // (título, subtítulo, progresso, ícone, categoria)
  static const lessons = [
    ('Poupar sem sofrer', 'Aula 3 de 5', 0.6, Icons.savings_outlined, 1),
    ('Juros compostos', 'Aula 1 de 4', 0.25, Icons.trending_up_rounded, 2),
    ('Gastos do dia a dia', 'Aula 4 de 4', 0.9, Icons.receipt_long_outlined, 3),
    ('Primeiros investimentos', 'Em breve', 0.0, Icons.lock_outline, 2),
  ];

  @override
  Widget build(BuildContext context) {
    final shown = lessons.where((l) => chip == 0 || l.$5 == chip).toList();
    return Scaffold(
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
              icon: Icon(Icons.account_balance_wallet_outlined), label: 'Carteira'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined), label: 'Aulas'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
      body: nav == 1
          ? const CarteiraTab()
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Olá, $nome',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  Text(papel == 'professor' ? 'Professor' : 'Nível 1 · Aprendiz',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                ]),
              ),
              IconButton(
                  onPressed: _sair,
                  tooltip: 'Sair',
                  icon: const Icon(Icons.logout_rounded, color: Colors.white)),
            ]),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text('Trilhas em destaque', style: serif(28)),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(padding: const EdgeInsets.all(20), children: [
                Reveal(
                  delay: 100,
                  child: Container(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saldo virtual',
                              style: TextStyle(color: Color(0xCCFFFFFF))),
                          SizedBox(height: 6),
                          Text(_brl(saldo),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 6),
                          Text('Dinheiro de mentira, aprendizado de verdade.',
                              style: TextStyle(
                                  color: Color(0xCCFFFFFF), fontSize: 12)),
                        ]),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: chips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ChoiceChip(
                      label: Text(chips[i]),
                      selected: chip == i,
                      showCheckmark: false,
                      selectedColor: kDark,
                      labelStyle: TextStyle(
                          color: chip == i ? Colors.white : kText,
                          fontWeight: FontWeight.w600),
                      onSelected: (_) => setState(() => chip = i),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < shown.length; i++)
                  Reveal(
                    key: ValueKey(shown[i].$1),
                    delay: 250 + i * 100,
                    child: _lessonCard(shown[i]),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _lessonCard((String, String, double, IconData, int) l) => Container(
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
            child: Icon(l.$4, color: kGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.$1,
                  style: const TextStyle(
                      color: kText, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(l.$2, style: const TextStyle(color: kMuted, fontSize: 12)),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: l.$3),
                duration: const Duration(milliseconds: 900),
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
        ]),
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