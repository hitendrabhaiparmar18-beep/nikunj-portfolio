import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PortfolioApp());

const bg = Color(0xFF080D19);
const panel = Color(0xFF111A2E);
const purple = Color(0xFF7667FF);
const cyan = Color(0xFF00D4FF);
const muted = Color(0xFFAAB4C8);

// CONFIGURATION: replace these values with your own public profile / EmailJS details.
const githubUsername = 'hitendrabhaiparmar18-beep';
const emailJsServiceId = 'service_x46rx31';
const emailJsTemplateId = 'template_vmwkjl2';
const emailJsPublicKey = 'OQeT2pd7VoijGF82g';
const contactEmail = 'hitendrabhaiparmar17@gmail.com';
const portfolioName = 'Nikunj Parmar';
const portfolioBrand = 'Nikunj Parmar.Dev';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: portfolioBrand,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark),
      useMaterial3: true,
      fontFamily: 'Arial',
    ),
    home: const PortfolioHome(),
  );
}

class PortfolioHome extends StatefulWidget {
  const PortfolioHome({super.key});
  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  final _scroll = ScrollController();
  final _sectionKeys = List.generate(6, (_) => GlobalKey());
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;


  @override
  void dispose() {
    _scroll.dispose();
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  void _go(int index) {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 750), curve: Curves.easeInOutCubic, alignment: .04);
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  Future<void> _downloadResume() async {
    try {
      final byteData = await rootBundle.load(
        'assets/Nikunj_Parmar_Resume.pdf',
      );

      final pdfBytes = byteData.buffer.asUint8List();

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Nikunj_Parmar_Resume.pdf',
      );
    } catch (e) {
      _snack('Resume open karvama error: $e');
    }
  }


  Future<void> _sendContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': emailJsServiceId,
          'template_id': emailJsTemplateId,
          'user_id': emailJsPublicKey,
          'template_params': {
            'from_name': _name.text.trim(),
            'reply_to': _email.text.trim(),
            'message': _message.text.trim(),
            'to_email': contactEmail,
          },
        }),
      );

      debugPrint('EmailJS Status: ${response.statusCode}');
      debugPrint('EmailJS Response: ${response.body}');

      if (response.statusCode == 200) {
        _name.clear();
        _email.clear();
        _message.clear();
        _snack('Message sent successfully!');
      } else {
        _snack(
          'EmailJS Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('EmailJS Exception: $e');
      _snack('Network Error: $e');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }



  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Drawer(
      backgroundColor: panel,
      child: SafeArea(child: Column(children: [
        const Padding(padding: EdgeInsets.all(24), child: Text(portfolioBrand, style: TextStyle(color: purple, fontSize: 25, fontWeight: FontWeight.bold))),
        ...List.generate(_labels.length, (i) => ListTile(title: Text(_labels[i]), onTap: () { Navigator.pop(context); _go(i); })),
      ])),
    ),
    body: SafeArea(child: Column(children: [
      _navigation(),
      Expanded(child: SingleChildScrollView(controller: _scroll, child: Column(children: [
        Container(key: _sectionKeys[0], child: _hero()),
        Container(key: _sectionKeys[1], child: _about()),
        Container(key: _sectionKeys[2], child: _skills()),
        Container(key: _sectionKeys[3], child: _projects()),
        Container(key: _sectionKeys[4], child: _services()),
        Container(key: _sectionKeys[5], child: _contact()),
        _footer(),
      ]))),
    ])),
  );

  static const _labels = ['Home', 'About', 'Skills', 'Projects', 'Services', 'Contact'];

  Widget _navigation() => LayoutBuilder(builder: (context, box) {
    final mobile = box.maxWidth < 760;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: Colors.white12))),
      child: Row(children: [
        const Text(portfolioBrand, style: TextStyle(color: purple, fontSize: 23, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (!mobile)
          ...List.generate(_labels.length, (i) => TextButton(onPressed: () => _go(i), child: Text(_labels[i], style: const TextStyle(color: Colors.white70))))
        else
          Builder(builder: (ctx) => IconButton(onPressed: () => Scaffold.of(ctx).openDrawer(), icon: const Icon(Icons.menu))),
      ]),
    );
  });

  Widget _hero() => _section(
    minHeight: 610,
    child: LayoutBuilder(builder: (context, box) {
      final mobile = box.maxWidth < 760;
      final intro = Column(
        crossAxisAlignment: mobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("HELLO, I'M A DEVELOPER", style: TextStyle(color: cyan, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Text.rich(TextSpan(children: [
            const TextSpan(text: "I'm "),
            const TextSpan(text: portfolioName, style: TextStyle(color: purple)),
            const TextSpan(text: '\nI build digital'),
            const TextSpan(text: '\nexperiences.', style: TextStyle(color: cyan)),
          ]), textAlign: mobile ? TextAlign.center : TextAlign.left, style: TextStyle(fontSize: mobile ? 42 : 64, height: 1.08, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          const AnimatedRoleText(),
          const SizedBox(height: 18),
          const Text('I create modern, responsive applications with Flutter, Dart, Firebase and APIs. I enjoy turning practical ideas into useful digital products.', style: TextStyle(color: muted, height: 1.8, fontSize: 15)),
          const SizedBox(height: 26),
          Wrap(alignment: mobile ? WrapAlignment.center : WrapAlignment.start, spacing: 12, runSpacing: 12, children: [
            _primaryButton('Explore Projects', Icons.work_outline, () => _go(3)),
            OutlinedButton.icon(onPressed: _downloadResume, icon: const Icon(Icons.download), label: const Text('Download Resume')),
          ]),
          const SizedBox(height: 22),
          Wrap(spacing: 18, children: [
            _social('GitHub', Icons.code, 'https://github.com/$githubUsername'),
            _social(
              'LinkedIn',
              Icons.work,
              'https://www.linkedin.com/in/nikunj-parmar-4b3744367/',
            ),
            _social('Email', Icons.mail_outline, 'mailto:$contactEmail'),
          ]),
        ],
      );
      final avatar = Container(
        width: mobile ? 210 : 300, height: mobile ? 210 : 300,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [purple, cyan]), boxShadow: [BoxShadow(color: purple.withOpacity(.28), blurRadius: 70)]),

        child: Padding(
          padding: const EdgeInsets.all(7),
          child: ClipOval(
            child: Image.asset(
              'assets/profile.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

      );
      if (mobile) {
        return Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [intro, const SizedBox(height: 38), avatar]);
      }
      return Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: intro), const SizedBox(width: 55), avatar,
      ]);
    }),
  );

  Widget _social(String label, IconData icon, String url) => InkWell(
    onTap: () => _openUrl(url),
    borderRadius: BorderRadius.circular(8),
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: cyan, size: 17), const SizedBox(width: 7), Text(label, style: const TextStyle(color: muted))])),
  );

  Future<void> _openUrl(String value) async {
    final uri = Uri.parse(value);
    if (value.contains('YOUR_GITHUB_USERNAME')) { _snack('Add your GitHub username in lib/main.dart first.'); return; }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) _snack('Could not open link.');
  }


  Widget _about() => _section(
    child: Column(
      children: [
        _heading('About', 'Me', 'A little introduction'),
        const SizedBox(height: 26),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: const Text(
            'I am a Diploma in Information Technology student at Gyanmanjari Innovative University, passionate about Flutter development and building modern digital solutions. I enjoy working with Flutter, Dart, Firebase, Python, and web technologies. Through hands-on projects, I have explored mobile app development, API integration, database management, and AI-powered solutions. I am continuously learning, improving my problem-solving skills, and turning creative ideas into practical applications.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              height: 2,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 30),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: const [
            _Stat('Flutter', 'Mobile development'),
            _Stat('Firebase', 'Cloud & database'),
            _Stat('Python', 'API development'),
          ],
        ),
      ],
    ),
  );


  Widget _skills() => _section(child: Column(children: [
    _heading('My', 'Skills', 'Tools and technologies I use'),
    const SizedBox(height: 30),
    _responsiveGrid([
      const _FeatureCard(title: 'Flutter & Dart', description: 'Cross-platform application development and reusable UI.', icon: Icons.flutter_dash),
      const _FeatureCard(title: 'Web Development', description: 'Responsive interfaces with HTML, CSS and JavaScript.', icon: Icons.language),
      const _FeatureCard(title: 'Firebase', description: 'Authentication, Firestore and app data integration.', icon: Icons.local_fire_department),
      const _FeatureCard(title: 'Python & FastAPI', description: 'Backend development and REST API integration.', icon: Icons.terminal),
      const _FeatureCard(title: 'Databases', description: 'MySQL, PostgreSQL and data modelling fundamentals.', icon: Icons.storage),
      const _FeatureCard(title: 'Git & GitHub', description: 'Version control, collaboration and project publishing.', icon: Icons.code),
    ]),
  ]));

  Widget _projects() => _section(child: Column(children: [
    _heading('Featured', 'Projects', 'Selected work and project concepts'),
    const SizedBox(height: 30),
    _responsiveGrid([
      _ProjectCard(title: 'Rural Artisan Digital Marketplace', description: 'A digital marketplace concept that helps rural artisans publish handmade products and reach customers.', stack: 'Flutter / Firebase / FastAPI', icon: Icons.storefront, problem: 'Artisans may have limited digital skills and reach beyond their local market.', solution: 'A guided seller experience, product catalogue and customer marketplace can make online selling easier.', outcome: 'Prototype concept focused on accessible onboarding and shared product data.'),
      _ProjectCard(title: 'SikshaSetu AI', description: 'A learning-outcome decision-support concept aligned with foundational learning needs.', stack: 'AI / Python / Data / Flutter', icon: Icons.school, problem: 'Learning gaps can remain hidden when assessment data is difficult to interpret.', solution: 'A hybrid decision-support workflow can turn assessment signals into actionable insights for educators.', outcome: 'Concept prototype; government data integrations require authorised access.'),
      _ProjectCard(title: 'AttendPro NFC', description: 'An NFC attendance prototype using an ESP32 device and a Flutter application.', stack: 'Flutter / ESP32 / Firebase', icon: Icons.nfc, problem: 'Manual attendance can take class time and introduce entry errors.', solution: 'An NFC tap workflow records attendance and presents role-based student and faculty views.', outcome: 'Prototype architecture with session controls and cloud attendance records.'),
      _ProjectCard(title: 'OpsMind AI', description: 'An AI business operations assistant concept with a FastAPI backend.', stack: 'Flutter / FastAPI / Python', icon: Icons.auto_awesome, problem: 'Business information can be spread across tools and difficult to act on quickly.', solution: 'A dashboard and conversational interface can bring operational signals into one workflow.', outcome: 'API-connected dashboard prototype with room for future agentic workflows.'),
    ]),
    const SizedBox(height: 55),
    _githubRepos(),
  ]));


  Future<List<Map<String, dynamic>>> _loadGithubRepos() async {
    if (githubUsername == 'YOUR_GITHUB_USERNAME') return [];
    final uri = Uri.https('api.github.com', '/users/$githubUsername/repos', {'sort': 'updated', 'per_page': '6'});
    final response = await http.get(uri, headers: {'Accept': 'application/vnd.github+json'});
    if (response.statusCode != 200) throw Exception('GitHub API returned ${response.statusCode}');
    final data = jsonDecode(response.body) as List;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Widget _githubRepos() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Icon(Icons.code, color: cyan, size: 25), const SizedBox(width: 10),
      const Expanded(child: Text('Latest GitHub Repositories', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800))),
      TextButton(onPressed: () => _openUrl('https://github.com/$githubUsername'), child: const Text('View GitHub')),
    ]),
    const SizedBox(height: 16),
    if (githubUsername == 'YOUR_GITHUB_USERNAME')
      const Text('Add your GitHub username in lib/main.dart to load your public repositories here.', style: TextStyle(color: muted))
    else
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadGithubRepos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator()));
          if (snapshot.hasError) return Text('Could not load GitHub repositories: ${snapshot.error}', style: const TextStyle(color: muted));
          final repos = snapshot.data ?? [];
          if (repos.isEmpty) return const Text('No public repositories found.', style: TextStyle(color: muted));
          return _responsiveGrid(repos.map((repo) => _RepoCard(repo: repo)).toList());
        },
      ),
  ]);

  Widget _services() => _section(child: Column(children: [
    _heading('My', 'Services', 'Ways I can contribute to your next project'),
    const SizedBox(height: 30),
    _responsiveGrid([
      const _FeatureCard(title: 'Flutter Development', description: 'Responsive, clean and reusable app interfaces.', icon: Icons.phone_android),
      const _FeatureCard(title: 'Website Development', description: 'Modern responsive websites for products and businesses.', icon: Icons.web),
      const _FeatureCard(title: 'Firebase Integration', description: 'Authentication, Firestore and cloud data workflows.', icon: Icons.cloud),
      const _FeatureCard(title: 'API Integration & Fixes', description: 'Connect REST APIs and troubleshoot UI or app issues.', icon: Icons.build_circle),
    ]),
  ]));


  Widget _contact() => _section(
    child: Column(
      children: [
        _heading(
          'Get In',
          'Touch',
          'Have a project in mind? Let’s talk',
        ),
        const SizedBox(height: 40),

        LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 760;

            final contactInfo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's Connect",
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "I'm always open to discussing new projects, "
                      "creative ideas and opportunities.",
                  style: TextStyle(
                    color: muted,
                    height: 1.7,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                _contactItem(
                  Icons.email_outlined,
                  'Email',
                  contactEmail,
                ),
                const SizedBox(height: 20),

                _contactItem(
                  Icons.location_on_outlined,
                  'Location',
                  'Bhavnagar, Gujarat, India',
                ),
                const SizedBox(height: 20),

                _contactItem(
                  Icons.code,
                  'GitHub',
                  'github.com/$githubUsername',
                  onTap: () => _openUrl(
                    'https://github.com/$githubUsername',
                  ),
                ),
                const SizedBox(height: 20),

                _contactItem(
                  Icons.work_outline,
                  'LinkedIn',
                  'Nikunj Parmar',
                  onTap: () => _openUrl(
                    'https://www.linkedin.com/in/nikunj-parmar-4b3744367/',
                  ),
                ),
              ],
            );

            final contactForm = Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _input(
                      _name,
                      'Your name',
                      validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    _input(
                      _email,
                      'Your email',
                      validator: (v) =>
                      (v == null ||
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(v.trim()))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    _input(
                      _message,
                      'Tell me about your project',
                      lines: 5,
                      validator: (v) =>
                      (v == null || v.trim().length < 10)
                          ? 'Please enter at least 10 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _sending ? null : _sendContact,
                        icon: _sending
                            ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(Icons.send),
                        label: Text(
                          _sending ? 'Sending...' : 'Send Message',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (mobile) {
              return Column(
                children: [
                  contactInfo,
                  const SizedBox(height: 35),
                  contactForm,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: contactInfo),
                const SizedBox(width: 35),
                Expanded(flex: 5, child: contactForm),
              ],
            );
          },
        ),
      ],
    ),
  );


  Widget _contactItem(
      IconData icon,
      String title,
      String value, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: cyan,
              size: 23,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _input(TextEditingController controller, String hint, {int lines = 1, String? Function(String?)? validator}) => TextFormField(
    controller: controller, maxLines: lines, validator: validator,
    decoration: InputDecoration(hintText: hint, filled: true, fillColor: bg, contentPadding: const EdgeInsets.all(16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent))),
  );

  Widget _responsiveGrid(List<Widget> children) => LayoutBuilder(builder: (context, box) {
    final columns = box.maxWidth > 900 ? 3 : box.maxWidth > 590 ? 2 : 1;
    final extent = columns == 1 ? 205.0 : columns == 2 ? 260.0 : 285.0;
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 18, mainAxisSpacing: 18, mainAxisExtent: extent),
      itemCount: children.length, itemBuilder: (_, i) => children[i],
    );
  });

  Widget _heading(String first, String accent, String subtitle) => Column(children: [
    Text.rich(TextSpan(children: [TextSpan(text: '$first '), TextSpan(text: accent, style: const TextStyle(color: purple))]), style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: cyan)),
  ]);

  Widget _section({required Widget child, double? minHeight}) => Container(
    width: double.infinity, constraints: minHeight == null ? null : BoxConstraints(minHeight: minHeight),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 76),
    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: child)),
  );

  Widget _primaryButton(String label, IconData icon, VoidCallback onPressed) => ElevatedButton.icon(
    onPressed: onPressed, icon: Icon(icon, size: 18), label: Text(label),
    style: ElevatedButton.styleFrom(backgroundColor: purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
  );

  Widget _footer() => Container(
    width: double.infinity, padding: const EdgeInsets.all(25),
    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
    child: const Text('© 2026 Nikunj.dev • Built with Flutter', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
  );
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.title, required this.description, required this.icon});
  final String title, description; final IconData icon;
  @override State<_FeatureCard> createState() => _FeatureCardState();
}
class _FeatureCardState extends State<_FeatureCard> {
  bool hover = false;
  @override Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hover = true), onExit: (_) => setState(() => hover = false),
    child: AnimatedContainer(duration: const Duration(milliseconds: 220), curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, hover ? -5 : 0, 0),
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: hover ? purple : Colors.white12), boxShadow: hover ? [BoxShadow(color: purple.withOpacity(.12), blurRadius: 24)] : []),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(widget.icon, color: cyan, size: 32), const SizedBox(height: 15),
        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8), Text(widget.description, style: const TextStyle(color: muted, height: 1.5, fontSize: 13)),
      ]),
    ),
  );
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({required this.title, required this.description, required this.stack, required this.icon, required this.problem, required this.solution, required this.outcome});
  final String title, description, stack, problem, solution, outcome; final IconData icon;
  @override State<_ProjectCard> createState() => _ProjectCardState();
}
class _ProjectCardState extends State<_ProjectCard> {
  bool hover = false;
  void _details() => showDialog(context: context, builder: (_) => AlertDialog(
    backgroundColor: panel, title: Text(widget.title),
    content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      _caseLabel('Problem', widget.problem), _caseLabel('Solution', widget.solution), _caseLabel('Current status', widget.outcome),
      const SizedBox(height: 12), Text('Tech stack: ${widget.stack}', style: const TextStyle(color: cyan)),
    ])),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
  ));
  Widget _caseLabel(String title, String body) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: cyan, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(body, style: const TextStyle(color: muted, height: 1.5))]));
  @override Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hover = true), onExit: (_) => setState(() => hover = false),
    child: AnimatedContainer(duration: const Duration(milliseconds: 220), transform: Matrix4.translationValues(0, hover ? -5 : 0, 0),
      padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: hover ? purple : Colors.white12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(widget.icon, color: cyan, size: 31), const SizedBox(height: 12),
        Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8), Expanded(child: Text(widget.description, style: const TextStyle(color: muted, height: 1.45, fontSize: 13), maxLines: 4, overflow: TextOverflow.ellipsis)),
        const SizedBox(height: 9), Text(widget.stack, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: cyan, fontSize: 11)),
        const SizedBox(height: 10), Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: _details, icon: const Icon(Icons.arrow_outward, size: 15), label: const Text('View case study'))),
      ]),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.title, this.subtitle); final String title, subtitle;
  @override Widget build(BuildContext context) => Container(width: 190, padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)), child: Column(children: [
    Text(title, style: const TextStyle(color: cyan, fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 5), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 11)),
  ]));
}

class AnimatedRoleText extends StatefulWidget {
  const AnimatedRoleText({super.key});

  @override
  State<AnimatedRoleText> createState() => _AnimatedRoleTextState();
}

class _AnimatedRoleTextState extends State<AnimatedRoleText> {
  final List<String> roles = const [
    'Flutter Developer',
    'Full Stack Developer',
    'App Builder',
    'Problem Solver',
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
    rotateRole();
  }

  Future<void> rotateRole() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      setState(() {
        index = (index + 1) % roles.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: Text(
        roles[index],
        key: ValueKey(roles[index]),
        style: const TextStyle(
          color: purple,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


class _RepoCard extends StatelessWidget {
  const _RepoCard({required this.repo});
  final Map<String, dynamic> repo;
  @override
  Widget build(BuildContext context) {
    final name = (repo['name'] ?? 'Repository').toString();
    final description = (repo['description'] ?? 'No description provided.').toString();
    final language = (repo['language'] ?? 'Code').toString();
    final stars = (repo['stargazers_count'] ?? 0).toString();
    final url = (repo['html_url'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.folder_open, color: cyan, size: 28),
        const SizedBox(height: 12),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12, height: 1.45)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Text(language, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: cyan, fontSize: 11))),
          const Icon(Icons.star_border, size: 15, color: muted), const SizedBox(width: 4),
          Text(stars, style: const TextStyle(color: muted, fontSize: 11)),
        ]),
        Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: url.isEmpty ? null : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication), child: const Text('Open repository'))),
      ]),
    );

  }
}
