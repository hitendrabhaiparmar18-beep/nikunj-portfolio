# Nikunj.dev — Premium Flutter Portfolio

## Included
- Dark navy / purple / cyan visual design retained from the starter project.
- Animated role headline in the hero section.
- Project case-study dialogs (problem, solution, current status).
- Resume PDF generation and print/save flow.
- Public GitHub repository integration (GitHub REST API).
- Contact form with validation and EmailJS delivery.
- Responsive navigation and cards with hover transitions.

## 1. Configure your profile
Open `lib/main.dart` and update these constants near the top:
- `githubUsername`
- `contactEmail`
- `portfolioName`
- `portfolioBrand`

Replace the current project descriptions and resume content with accurate information about your own work before publishing.

## 2. Enable GitHub repositories
Set `githubUsername` to your GitHub username. Public repositories are loaded automatically from the GitHub public API. No token is required for this public endpoint. The API may rate-limit frequent unauthenticated requests.

## 3. Make the contact form send real emails
The form uses EmailJS. Create an account at https://www.emailjs.com/ and:
1. Add an Email Service.
2. Create an Email Template with variables: `from_name`, `reply_to`, `message`, and `to_email`.
3. Set the template recipient to your own inbox (or use the `to_email` variable if your template supports it).
4. Copy your Service ID, Template ID and Public Key.
5. Replace `emailJsServiceId`, `emailJsTemplateId`, and `emailJsPublicKey` in `lib/main.dart`.

The public EmailJS key is intended for client-side use; configure allowed origins and abuse protections in EmailJS. Do not put private server keys in Flutter code. Test delivery on Chrome and Android. Browser/network restrictions can prevent delivery; check EmailJS dashboard and browser console if it fails.

## 4. Run
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

For Android:
```bash
flutter run
```

## 5. Resume
The Download Resume button generates a starter PDF with the details currently in `main.dart`. Edit the profile, skills, projects and contact constants/text before sharing. On desktop/web, the PDF print dialog can be used to save the PDF.

## Notes
- The project name and `Nikunj.dev` brand are retained from the existing starter source. Change them if they are placeholders.
- GitHub username and EmailJS credentials are placeholders until you configure them.
- The case studies are based on the project descriptions in the starter portfolio. Update their status to match what is actually implemented.
