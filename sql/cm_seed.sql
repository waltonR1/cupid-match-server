-- ----------------------------
-- Cupid Match sample seed data
-- Generated from doc/reference-from-app/mock-server/db.json
-- Run after sql/cm_schema.sql.
-- ----------------------------

set names utf8mb4;

insert into cm_users (id, account_name, avatar_url, preferred_locale, status, created_at, updated_at) values
  ('u-001', 'Lin', '', 'zh', 'active', '2026-01-18 00:00:00', '2026-05-27 18:33:11');


insert into cm_auth_identities (id, user_id, provider, identifier, password_hash, verified_at, created_at, updated_at) values
  ('auth-001', 'u-001', 'email', 'lin@example.com', 'mock-sha256:cGFzc3dvcmQxMjM=', '2026-01-18 00:00:00', '2026-01-18 00:00:00', '2026-01-18 00:00:00'),
  ('auth-002', 'u-001', 'phone', '13333333333', 'mock-sha256:cGFzc3dvcmQxMjM=', '2026-06-01 12:16:53', '2026-06-01 12:16:53', '2026-06-01 12:16:53');


insert into cm_user_security_settings (id, user_id, mfa_enabled, mfa_method, mfa_identity_id, mfa_enabled_at, last_challenge_at, created_at, updated_at) values
  ('mfa-setting-001', 'u-001', 1, 'email', 'auth-001', '2026-05-31 14:39:34', '2026-06-01 12:50:47', '2026-05-31 14:39:34', '2026-06-01 12:50:47');


insert into cm_user_security_challenges (id, user_id, action, method, identity_id, status, challenge_token, expires_at, verified_at, consumed_at, created_at, updated_at) values
  ('security-challenge-001', 'u-001', 'export_data', 'email', 'auth-001', 'consumed', 'challenge-security-token-001-1780238394772', '2026-05-31 14:44:54', '2026-05-31 14:39:54', '2026-05-31 14:39:54', '2026-05-31 14:39:39', '2026-05-31 14:39:54'),
  ('security-challenge-002', 'u-001', 'export_data', 'email', 'auth-001', 'pending', null, '2026-05-31 14:45:04', null, null, '2026-05-31 14:40:04', '2026-05-31 14:40:04'),
  ('security-challenge-003', 'u-001', 'export_data', 'email', 'auth-001', 'pending', null, '2026-05-31 14:46:05', null, null, '2026-05-31 14:41:05', '2026-05-31 14:41:05'),
  ('security-challenge-004', 'u-001', 'export_data', 'email', 'auth-001', 'pending', null, '2026-06-01 12:55:47', null, null, '2026-06-01 12:50:47', '2026-06-01 12:50:47');


insert into cm_user_preferences (id, user_id, preferred_city_code, preferred_contact_channel, staff_contact_enabled, family_assist_enabled, introduction_updates_enabled, event_reminders_enabled, service_announcements_enabled, marketing_emails_enabled, analytics_consent_enabled, created_at, updated_at) values
  ('pref-001', 'u-001', 'paris', 'email', 1, 1, 1, 1, 1, 0, 0, '2026-01-01 00:00:00', '2026-05-27 18:36:02');


insert into cm_legal_documents (id, type, version, status, effective_at, created_at, updated_at) values
  ('ld-001', 'terms', '1.0', 'active', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ld-002', 'privacy', '1.0', 'active', '2026-01-01 00:00:00', '2026-01-01 00:00:00', '2026-01-01 00:00:00');


insert into cm_legal_document_contents (id, document_id, locale, title, sections, created_at, updated_at) values
  ('ldc-001-01', 'ld-001', 'zh', 'Cupid Match 平台服务条款', '[{"heading":"第一条 定义与接受","clauses":[{"number":"1.1","body":"Cupid Match 平台（以下简称\\"平台\\"）是由 Cupid Match 运营方（以下简称\\"我们\\"）提供的婚恋中介撮合服务平台。"},{"number":"1.2","body":"本服务条款（以下简称\\"条款\\"）是您与平台之间关于使用平台服务的完整协议。您在注册时勾选\\"我已阅读并同意\\"，即表示您已完整阅读、充分理解并自愿接受本条款的全部内容。"},{"number":"1.3","body":"平台可能通过弹窗、页面提示、站内信等方式向您发送通知。您继续使用平台服务即表示您同意接收此类通知。"}],"sortOrder":1},{"heading":"第二条 账号注册与安全","clauses":[{"number":"2.1","body":"注册资格：您确认您年满 18 周岁，具有完全民事行为能力。如果您代表他人（如子女）注册，您需获得该人士的明确授权。"},{"number":"2.2","body":"注册信息：您应提供真实、准确、完整的注册信息，包括但不限于姓名、邮箱或手机号。注册信息发生变更时，您应及时更新。"},{"number":"2.3","body":"账号安全：您对账号下的所有活动负责。请妥善保管您的登录凭证，不得将账号出借、转让或授权他人使用。如发现账号被盗用，应立即通知平台。"},{"number":"2.4","body":"实名认证：平台有权要求您完成实名认证。未通过实名认证的账号，平台可限制部分功能的使用。"}],"sortOrder":2},{"heading":"第三条 服务内容","clauses":[{"number":"3.1","body":"平台提供以下核心服务：\\n（a）个人资料创建与展示：您可创建个人相亲资料，包括个人信息、照片、择偶偏好等；\\n（b）智能匹配与推荐：平台根据您的资料和偏好，推荐匹配度较高的其他用户；\\n（c）资料浏览与搜索：您可在平台范围内浏览和筛选其他用户的公开资料；\\n（d）私人介绍服务：平台顾问根据双方情况提供定向撮合介绍服务；\\n（e）线下活动：平台定期组织线下交友活动，您可报名参加；\\n（f）顾问服务：平台顾问提供婚恋咨询、资料优化、撮合跟进等服务。"},{"number":"3.2","body":"平台保留根据运营需要调整、增减服务内容的权利。重大调整将提前 7 日在平台上公告。"}],"sortOrder":3},{"heading":"第四条 会员与付费","clauses":[{"number":"4.1","body":"平台提供免费基础服务和付费会员服务。免费用户可访问基本功能，付费会员享有更多权益（如增加私人介绍额度、优先活动报名、专属顾问服务等）。"},{"number":"4.2","body":"会员套餐和价格以平台公布为准。平台可能不时调整套餐内容和价格，调整前已购买的套餐不受影响。"},{"number":"4.3","body":"除法律规定的情形外，已支付的会员费用不予退还。"},{"number":"4.4","body":"会员到期后，您将恢复免费用户权限。平台保留在会员到期前提醒您续费的权利。"}],"sortOrder":4},{"heading":"第五条 用户行为规范","clauses":[{"number":"5.1","body":"您承诺在使用平台过程中遵守以下规范：\\n（a）遵守中华人民共和国法律法规及您所在地区的适用法律；\\n（b）遵守社会公序良俗，尊重他人合法权益；\\n（c）发布真实、合法、准确的信息，不编造虚假身份、年龄、婚姻状况、职业等资料；\\n（d）不利用平台从事任何违法违规活动，包括但不限于诈骗、传销、赌博、色情服务等。"},{"number":"5.2","body":"禁止行为包括但不限于：\\n（a）骚扰、辱骂、恐吓、跟踪其他用户；\\n（b）未经许可收集、存储、传播其他用户的个人信息；\\n（c）发布商业广告、垃圾信息或与婚恋交友无关的内容；\\n（d）绕开平台私下交易或进行资金往来；\\n（e）利用技术手段干扰平台正常运营（如爬虫、刷量、注入攻击等）；\\n（f）冒用平台名义或冒充平台工作人员。"}],"sortOrder":5},{"heading":"第六条 信息审核与处置","clauses":[{"number":"6.1","body":"平台有权对用户发布的资料、照片、文字等内容进行审核。审核标准包括但不限于真实性、合法性、合规性。"},{"number":"6.2","body":"如发现您发布的内容违反本条款或法律法规，平台有权采取以下一项或多项措施：\\n（a）要求您限期修改或删除违规内容；\\n（b）暂时或永久限制您发布内容的权限；\\n（c）暂时冻结或永久关闭您的账号；\\n（d）向有关主管部门报告；\\n（e）保留追究法律责任的权利。"},{"number":"6.3","body":"平台对用户内容的审核不意味着平台认可该内容的真实性或合法性。用户对其发布的内容独立承担法律责任。"}],"sortOrder":6},{"heading":"第七条 隐私保护","clauses":[{"number":"7.1","body":"平台高度重视您的隐私保护。您的个人信息将按照《隐私说明》进行收集、使用和保护。《隐私说明》是本条款不可分割的组成部分。"},{"number":"7.2","body":"未经您的明确同意，平台不会向第三方披露您的联系方式（手机号、邮箱、微信号等）。私人介绍成功后，联系方式在双方确认的情况下方可交换。"},{"number":"7.3","body":"您授权平台在以下范围内使用您的资料信息：\\n（a）在平台内展示您的个人资料（按您的隐私设置控制可见范围）；\\n（b）向平台顾问展示您的资料以便提供撮合服务；\\n（c）向您推荐匹配度较高的其他用户；\\n（d）用于平台服务的改进和优化（匿名化处理后）。"}],"sortOrder":7},{"heading":"第八条 知识产权","clauses":[{"number":"8.1","body":"平台的所有内容，包括但不限于文字、图片、图标、界面设计、软件代码、数据汇编等，均受知识产权法律保护。未经平台书面许可，任何人不得复制、修改、传播或利用。"},{"number":"8.2","body":"您在平台上发布的内容（照片、文字等），您保留所有权。您授予平台在平台范围内使用、展示、分发这些内容的非独占许可，以便为您提供服务。"},{"number":"8.3","body":"您保证您在平台上发布的内容不侵犯任何第三方的知识产权或其他合法权益。如因此给平台造成损失，您应承担赔偿责任。"}],"sortOrder":8},{"heading":"第九条 免责声明","clauses":[{"number":"9.1","body":"平台作为婚恋信息撮合平台，尽力为用户提供真实、可靠的服务，但在以下范围内不承担责任：\\n（a）平台不保证任何匹配推荐或活动必然促成恋爱关系或婚姻；\\n（b）平台不对用户自行发布的信息的准确性、完整性承担保证责任；\\n（c）用户之间的线下交往、资金往来由用户自行判断风险并承担后果。"},{"number":"9.2","body":"因不可抗力（自然灾害、战争、政策变化、网络攻击等）导致服务中断或数据丢失的，平台不承担责任，但应在合理时间内恢复服务。"},{"number":"9.3","body":"您在与其他用户交往过程中应保持理性判断，注意人身和财产安全。平台建议首次线下见面选择公共场所。"}],"sortOrder":9},{"heading":"第十条 违约责任与赔偿","clauses":[{"number":"10.1","body":"如您违反本条款，给平台或第三方造成损失的，您应承担相应的赔偿责任。"},{"number":"10.2","body":"平台的赔偿责任仅限于直接损失，且总额不超过您在过去 12 个月内向平台支付的费用总额。"},{"number":"10.3","body":"本条款的任何规定不限制或排除法律禁止限制或排除的责任。"}],"sortOrder":10},{"heading":"第十一条 条款修改","clauses":[{"number":"11.1","body":"平台有权根据需要修改本条款。修改后的条款将在平台公布，公布后继续使用平台服务即表示您接受修改后的条款。"},{"number":"11.2","body":"如您不同意修改后的条款，您应停止使用平台服务并注销账号。"},{"number":"11.3","body":"重大条款修改，平台将通过站内信或邮件方式提前 7 日通知您。"}],"sortOrder":11},{"heading":"第十二条 适用法律与争议解决","clauses":[{"number":"12.1","body":"本条款的订立、执行和解释适用中华人民共和国法律。"},{"number":"12.2","body":"因本条款引起的或与本条款有关的争议，双方应友好协商解决。协商不成的，任何一方均可向平台运营方所在地有管辖权的人民法院提起诉讼。"},{"number":"12.3","body":"本条款的部分条款无效不影响其余条款的效力。"}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ldc-001-02', 'ld-001', 'en', 'Cupid Match Platform Terms of Service', '[{"heading":"Article 1 Definitions and Acceptance","clauses":[{"number":"1.1","body":"The Cupid Match platform (the Platform) is a matchmaking and relationship-introduction service platform provided by the operator of Cupid Match (we, us, or our)."},{"number":"1.2","body":"These Terms of Service (the Terms) constitute the complete agreement between you and the Platform regarding your use of Platform services. By ticking I have read and agree during registration, you confirm that you have read, understood, and voluntarily accepted all provisions of these Terms."},{"number":"1.3","body":"The Platform may send notices to you through pop-ups, page prompts, in-app messages, and similar methods. Your continued use of Platform services means that you agree to receive such notices."}],"sortOrder":1},{"heading":"Article 2 Account Registration and Security","clauses":[{"number":"2.1","body":"Registration eligibility: You confirm that you are at least 18 years old and have full civil capacity. If you register on behalf of another person, such as your child, you must have that person’s express authorization."},{"number":"2.2","body":"Registration information: You must provide true, accurate, and complete registration information, including but not limited to your name, email address, or phone number. You must update such information promptly if it changes."},{"number":"2.3","body":"Account security: You are responsible for all activities under your account. You must keep your login credentials secure and may not lend, transfer, or authorize others to use your account. If you discover unauthorized use of your account, you must notify the Platform immediately."},{"number":"2.4","body":"Identity verification: The Platform has the right to require you to complete identity verification. If your account does not pass identity verification, the Platform may restrict your use of certain functions."}],"sortOrder":2},{"heading":"Article 3 Services","clauses":[{"number":"3.1","body":"The Platform provides the following core services:\\n(a) profile creation and display: you may create a matchmaking profile, including personal information, photos, and partner preferences;\\n(b) intelligent matching and recommendations: the Platform recommends other users with higher compatibility based on your profile and preferences;\\n(c) profile browsing and search: you may browse and filter other users’ public profiles within the Platform;\\n(d) private introduction services: Platform advisors provide targeted matchmaking introductions based on both parties’ circumstances;\\n(e) offline events: the Platform regularly organizes offline social events for which you may register;\\n(f) advisor services: Platform advisors may provide relationship consultation, profile optimization, matchmaking follow-up, and related services."},{"number":"3.2","body":"The Platform reserves the right to adjust, add, or remove services based on operational needs. Material adjustments will be announced on the Platform 7 days in advance."}],"sortOrder":3},{"heading":"Article 4 Membership and Paid Services","clauses":[{"number":"4.1","body":"The Platform provides free basic services and paid membership services. Free users may access basic functions. Paid members enjoy additional benefits, such as increased private introduction quotas, priority event registration, and dedicated advisor services."},{"number":"4.2","body":"Membership packages and prices are subject to the information published by the Platform. The Platform may adjust package content and pricing from time to time. Packages already purchased before an adjustment are not affected."},{"number":"4.3","body":"Except where required by law, paid membership fees are non-refundable."},{"number":"4.4","body":"After your membership expires, your account will return to free-user permissions. The Platform reserves the right to remind you to renew before expiration."}],"sortOrder":4},{"heading":"Article 5 User Conduct","clauses":[{"number":"5.1","body":"You undertake to comply with the following rules when using the Platform:\\n(a) comply with the laws and regulations of the People’s Republic of China and the applicable laws of your location;\\n(b) comply with public order and good morals and respect the lawful rights and interests of others;\\n(c) publish true, lawful, and accurate information and not fabricate false identity, age, marital status, occupation, or similar information;\\n(d) not use the Platform for any illegal or non-compliant activity, including but not limited to fraud, pyramid schemes, gambling, or sexual services."},{"number":"5.2","body":"Prohibited conduct includes but is not limited to:\\n(a) harassing, insulting, threatening, or stalking other users;\\n(b) collecting, storing, or disseminating other users’ personal information without permission;\\n(c) publishing commercial advertisements, spam, or content unrelated to matchmaking or dating;\\n(d) bypassing the Platform for private transactions or fund transfers;\\n(e) using technical means to interfere with normal Platform operations, such as crawlers, traffic manipulation, or injection attacks;\\n(f) using the Platform’s name without authorization or impersonating Platform staff."}],"sortOrder":5},{"heading":"Article 6 Content Review and Handling","clauses":[{"number":"6.1","body":"The Platform has the right to review materials, photos, text, and other content published by users. Review standards include but are not limited to authenticity, legality, and compliance."},{"number":"6.2","body":"If content you publish violates these Terms or applicable laws and regulations, the Platform has the right to take one or more of the following measures:\\n(a) require you to modify or delete the violating content within a specified period;\\n(b) temporarily or permanently restrict your permission to publish content;\\n(c) temporarily freeze or permanently close your account;\\n(d) report the matter to competent authorities;\\n(e) reserve the right to pursue legal liability."},{"number":"6.3","body":"The Platform’s review of user content does not mean that the Platform recognizes the authenticity or legality of such content. Users independently bear legal responsibility for the content they publish."}],"sortOrder":6},{"heading":"Article 7 Privacy Protection","clauses":[{"number":"7.1","body":"The Platform attaches great importance to protecting your privacy. Your personal information will be collected, used, and protected in accordance with the Privacy Notice. The Privacy Notice forms an integral part of these Terms."},{"number":"7.2","body":"Without your express consent, the Platform will not disclose your contact details, such as phone number, email address, or WeChat ID, to third parties. After a private introduction succeeds, contact details may be exchanged only upon confirmation by both parties."},{"number":"7.3","body":"You authorize the Platform to use your profile information within the following scope:\\n(a) display your profile within the Platform, subject to your privacy settings;\\n(b) show your profile to Platform advisors so that they may provide matchmaking services;\\n(c) recommend other users with higher compatibility to you;\\n(d) improve and optimize Platform services after anonymization."}],"sortOrder":7},{"heading":"Article 8 Intellectual Property","clauses":[{"number":"8.1","body":"All Platform content, including but not limited to text, images, icons, interface designs, software code, and data compilations, is protected by intellectual property laws. No person may copy, modify, distribute, or use such content without the Platform’s written permission."},{"number":"8.2","body":"You retain ownership of content you publish on the Platform, such as photos and text. You grant the Platform a non-exclusive license to use, display, and distribute such content within the Platform for the purpose of providing services to you."},{"number":"8.3","body":"You warrant that content you publish on the Platform does not infringe the intellectual property rights or other lawful rights and interests of any third party. If losses are caused to the Platform as a result, you shall be liable for compensation."}],"sortOrder":8},{"heading":"Article 9 Disclaimers","clauses":[{"number":"9.1","body":"As a matchmaking information and introduction platform, the Platform strives to provide authentic and reliable services, but does not assume liability within the following scope:\\n(a) the Platform does not guarantee that any matching recommendation or event will necessarily lead to a romantic relationship or marriage;\\n(b) the Platform does not guarantee the accuracy or completeness of information independently published by users;\\n(c) users must independently assess and bear the consequences of offline interactions and fund transfers between users."},{"number":"9.2","body":"The Platform is not liable for service interruption or data loss caused by force majeure, such as natural disasters, war, policy changes, or cyberattacks, but will restore services within a reasonable time."},{"number":"9.3","body":"You should maintain rational judgment when interacting with other users and pay attention to personal and property safety. The Platform recommends that first offline meetings take place in public places."}],"sortOrder":9},{"heading":"Article 10 Breach Liability and Compensation","clauses":[{"number":"10.1","body":"If you violate these Terms and cause losses to the Platform or any third party, you shall bear corresponding compensation liability."},{"number":"10.2","body":"The Platform’s compensation liability is limited to direct losses and shall not exceed the total fees you paid to the Platform during the preceding 12 months."},{"number":"10.3","body":"No provision of these Terms limits or excludes liability where such limitation or exclusion is prohibited by law."}],"sortOrder":10},{"heading":"Article 11 Modification of Terms","clauses":[{"number":"11.1","body":"The Platform has the right to modify these Terms as needed. Modified Terms will be published on the Platform. Your continued use of Platform services after publication means that you accept the modified Terms."},{"number":"11.2","body":"If you do not agree to the modified Terms, you should stop using Platform services and cancel your account."},{"number":"11.3","body":"For material modifications to these Terms, the Platform will notify you 7 days in advance by in-app message or email."}],"sortOrder":11},{"heading":"Article 12 Governing Law and Dispute Resolution","clauses":[{"number":"12.1","body":"The formation, performance, and interpretation of these Terms are governed by the laws of the People’s Republic of China."},{"number":"12.2","body":"Any dispute arising out of or relating to these Terms shall first be resolved through friendly consultation. If consultation fails, either party may bring a lawsuit before a competent people’s court at the place where the Platform operator is located."},{"number":"12.3","body":"The invalidity of any part of these Terms does not affect the validity of the remaining provisions."}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ldc-001-03', 'ld-001', 'fr', 'Conditions d utilisation de la plateforme Cupid Match', '[{"heading":"Article 1 Definitions et acceptation","clauses":[{"number":"1.1","body":"La plateforme Cupid Match (la Plateforme) est une plateforme de mise en relation matrimoniale et de services d introduction fournie par l operateur de Cupid Match (nous, notre ou nos)."},{"number":"1.2","body":"Les presentes conditions d utilisation (les Conditions) constituent l accord complet entre vous et la Plateforme concernant l utilisation des services de la Plateforme. En cochant J ai lu et j accepte lors de l inscription, vous confirmez avoir lu integralement, compris pleinement et accepte volontairement toutes les dispositions des presentes Conditions."},{"number":"1.3","body":"La Plateforme peut vous envoyer des notifications par fenetre contextuelle, message sur page, message interne ou moyen similaire. La poursuite de l utilisation des services de la Plateforme vaut acceptation de recevoir ces notifications."}],"sortOrder":1},{"heading":"Article 2 Inscription et securite du compte","clauses":[{"number":"2.1","body":"Eligibilite a l inscription : vous confirmez avoir au moins 18 ans et disposer de la pleine capacite civile. Si vous vous inscrivez pour le compte d une autre personne, par exemple votre enfant, vous devez obtenir son autorisation expresse."},{"number":"2.2","body":"Informations d inscription : vous devez fournir des informations d inscription veridiques, exactes et completes, y compris notamment votre nom, votre adresse email ou votre numero de telephone. Vous devez les mettre a jour rapidement en cas de changement."},{"number":"2.3","body":"Securite du compte : vous etes responsable de toutes les activites effectuees avec votre compte. Vous devez proteger vos identifiants de connexion et ne pouvez pas preter, transferer ou autoriser un tiers a utiliser votre compte. En cas d utilisation non autorisee, vous devez avertir immediatement la Plateforme."},{"number":"2.4","body":"Verification d identite : la Plateforme peut vous demander de completer une verification d identite. Si le compte ne reussit pas cette verification, la Plateforme peut limiter l acces a certaines fonctions."}],"sortOrder":2},{"heading":"Article 3 Contenu des services","clauses":[{"number":"3.1","body":"La Plateforme fournit les services principaux suivants :\\n(a) creation et affichage du profil : vous pouvez creer un profil de rencontre comprenant des informations personnelles, des photos et des preferences de partenaire ;\\n(b) mise en relation intelligente et recommandations : la Plateforme recommande d autres utilisateurs ayant une compatibilite elevee selon votre profil et vos preferences ;\\n(c) consultation et recherche de profils : vous pouvez consulter et filtrer les profils publics d autres utilisateurs dans le cadre de la Plateforme ;\\n(d) service d introduction privee : les conseillers de la Plateforme fournissent des introductions ciblees selon la situation des deux parties ;\\n(e) evenements hors ligne : la Plateforme organise regulierement des evenements de rencontre auxquels vous pouvez vous inscrire ;\\n(f) service de conseil : les conseillers peuvent fournir consultation, optimisation de profil, suivi de mise en relation et services connexes."},{"number":"3.2","body":"La Plateforme se reserve le droit d ajuster, d ajouter ou de supprimer des services selon ses besoins operationnels. Les ajustements importants seront annonces sur la Plateforme 7 jours a l avance."}],"sortOrder":3},{"heading":"Article 4 Abonnement et services payants","clauses":[{"number":"4.1","body":"La Plateforme propose des services de base gratuits et des services d abonnement payants. Les utilisateurs gratuits peuvent acceder aux fonctions de base. Les membres payants beneficient de droits supplementaires, tels que quotas d introduction privee augmentes, priorite d inscription aux evenements et service de conseiller dedie."},{"number":"4.2","body":"Les formules et prix d abonnement sont ceux publies par la Plateforme. La Plateforme peut ajuster le contenu et le prix des formules. Les formules deja achetees avant l ajustement ne sont pas affectees."},{"number":"4.3","body":"Sauf disposition legale contraire, les frais d abonnement deja payes ne sont pas remboursables."},{"number":"4.4","body":"A l expiration de votre abonnement, votre compte revient aux autorisations d utilisateur gratuit. La Plateforme se reserve le droit de vous rappeler le renouvellement avant expiration."}],"sortOrder":4},{"heading":"Article 5 Regles de conduite des utilisateurs","clauses":[{"number":"5.1","body":"Vous vous engagez a respecter les regles suivantes lors de l utilisation de la Plateforme :\\n(a) respecter les lois et reglements de la Republique populaire de Chine et les lois applicables de votre lieu de residence ;\\n(b) respecter l ordre public, les bonnes moeurs et les droits legitimes d autrui ;\\n(c) publier des informations veridiques, legales et exactes, sans fabriquer de fausse identite, age, situation matrimoniale, profession ou information similaire ;\\n(d) ne pas utiliser la Plateforme pour des activites illegales ou non conformes, y compris notamment fraude, systeme pyramidal, jeux d argent ou services sexuels."},{"number":"5.2","body":"Les comportements interdits comprennent notamment :\\n(a) harceler, insulter, menacer ou suivre d autres utilisateurs ;\\n(b) collecter, stocker ou diffuser les informations personnelles d autres utilisateurs sans autorisation ;\\n(c) publier de la publicite commerciale, du spam ou du contenu sans lien avec les rencontres ;\\n(d) contourner la Plateforme pour realiser des transactions privees ou des transferts d argent ;\\n(e) utiliser des moyens techniques pour perturber le fonctionnement normal de la Plateforme, tels que robots d exploration, manipulation de trafic ou attaques par injection ;\\n(f) utiliser le nom de la Plateforme sans autorisation ou se faire passer pour un membre du personnel de la Plateforme."}],"sortOrder":5},{"heading":"Article 6 Verification et traitement du contenu","clauses":[{"number":"6.1","body":"La Plateforme a le droit de verifier les informations, photos, textes et autres contenus publies par les utilisateurs. Les criteres de verification comprennent notamment authenticite, legalite et conformite."},{"number":"6.2","body":"Si un contenu que vous publiez viole les presentes Conditions ou les lois et reglements applicables, la Plateforme peut prendre une ou plusieurs des mesures suivantes :\\n(a) vous demander de modifier ou supprimer le contenu non conforme dans un delai determine ;\\n(b) limiter temporairement ou definitivement votre droit de publier du contenu ;\\n(c) suspendre temporairement ou fermer definitivement votre compte ;\\n(d) signaler la situation aux autorites competentes ;\\n(e) se reserver le droit d engager votre responsabilite juridique."},{"number":"6.3","body":"La verification du contenu par la Plateforme ne signifie pas que la Plateforme reconnait son authenticite ou sa legalite. Les utilisateurs assument seuls la responsabilite juridique du contenu qu ils publient."}],"sortOrder":6},{"heading":"Article 7 Protection de la vie privee","clauses":[{"number":"7.1","body":"La Plateforme attache une grande importance a la protection de votre vie privee. Vos informations personnelles sont collectees, utilisees et protegees conformement a la Politique de confidentialite. La Politique de confidentialite fait partie integrante des presentes Conditions."},{"number":"7.2","body":"Sans votre consentement explicite, la Plateforme ne divulguera pas vos coordonnees, telles que telephone, email ou identifiant WeChat, a des tiers. Apres une introduction privee reussie, les coordonnees ne peuvent etre echangees qu avec confirmation des deux parties."},{"number":"7.3","body":"Vous autorisez la Plateforme a utiliser vos informations de profil dans les limites suivantes :\\n(a) afficher votre profil sur la Plateforme selon vos parametres de confidentialite ;\\n(b) montrer votre profil aux conseillers de la Plateforme afin de fournir le service de mise en relation ;\\n(c) vous recommander d autres utilisateurs avec une compatibilite elevee ;\\n(d) ameliorer et optimiser les services de la Plateforme apres anonymisation."}],"sortOrder":7},{"heading":"Article 8 Propriete intellectuelle","clauses":[{"number":"8.1","body":"Tous les contenus de la Plateforme, y compris notamment textes, images, icones, conception d interface, code logiciel et compilations de donnees, sont proteges par les lois relatives a la propriete intellectuelle. Nul ne peut copier, modifier, diffuser ou utiliser ces contenus sans autorisation ecrite de la Plateforme."},{"number":"8.2","body":"Vous conservez la propriete des contenus que vous publiez sur la Plateforme, tels que photos et textes. Vous accordez a la Plateforme une licence non exclusive pour utiliser, afficher et distribuer ces contenus dans le cadre de la Plateforme afin de vous fournir les services."},{"number":"8.3","body":"Vous garantissez que les contenus que vous publiez sur la Plateforme ne portent pas atteinte aux droits de propriete intellectuelle ou autres droits legitimes de tiers. Si la Plateforme subit un prejudice de ce fait, vous devrez l indemniser."}],"sortOrder":8},{"heading":"Article 9 Exclusions de responsabilite","clauses":[{"number":"9.1","body":"En tant que plateforme d information et de mise en relation matrimoniale, la Plateforme s efforce de fournir des services authentiques et fiables, mais n assume pas de responsabilite dans les cas suivants :\\n(a) la Plateforme ne garantit pas qu une recommandation ou un evenement aboutira necessairement a une relation amoureuse ou a un mariage ;\\n(b) la Plateforme ne garantit pas l exactitude ou l exhaustivite des informations publiees directement par les utilisateurs ;\\n(c) les interactions hors ligne et transferts d argent entre utilisateurs relevent de leur propre evaluation des risques et de leur propre responsabilite."},{"number":"9.2","body":"La Plateforme n est pas responsable des interruptions de service ou pertes de donnees causees par un cas de force majeure, tel que catastrophe naturelle, guerre, changement de politique ou cyberattaque, mais elle retablira les services dans un delai raisonnable."},{"number":"9.3","body":"Vous devez faire preuve de discernement lors de vos interactions avec d autres utilisateurs et veiller a votre securite personnelle et patrimoniale. La Plateforme recommande que la premiere rencontre hors ligne ait lieu dans un endroit public."}],"sortOrder":9},{"heading":"Article 10 Responsabilite pour violation et indemnisation","clauses":[{"number":"10.1","body":"Si vous violez les presentes Conditions et causez un prejudice a la Plateforme ou a un tiers, vous devez assumer la responsabilite d indemnisation correspondante."},{"number":"10.2","body":"La responsabilite d indemnisation de la Plateforme est limitee aux pertes directes et ne peut depasser le montant total des frais que vous avez payes a la Plateforme au cours des 12 derniers mois."},{"number":"10.3","body":"Aucune disposition des presentes Conditions ne limite ou exclut une responsabilite lorsque la loi interdit une telle limitation ou exclusion."}],"sortOrder":10},{"heading":"Article 11 Modification des Conditions","clauses":[{"number":"11.1","body":"La Plateforme peut modifier les presentes Conditions si necessaire. Les Conditions modifiees seront publiees sur la Plateforme. La poursuite de l utilisation des services apres publication vaut acceptation des Conditions modifiees."},{"number":"11.2","body":"Si vous n acceptez pas les Conditions modifiees, vous devez cesser d utiliser les services de la Plateforme et supprimer votre compte."},{"number":"11.3","body":"En cas de modification importante des Conditions, la Plateforme vous en informera 7 jours a l avance par message interne ou email."}],"sortOrder":11},{"heading":"Article 12 Loi applicable et reglement des litiges","clauses":[{"number":"12.1","body":"La formation, l execution et l interpretation des presentes Conditions sont regies par les lois de la Republique populaire de Chine."},{"number":"12.2","body":"Tout litige decoulant des presentes Conditions ou s y rapportant doit d abord etre resolu par consultation amiable. A defaut d accord, chaque partie peut saisir le tribunal populaire competent du lieu ou se trouve l operateur de la Plateforme."},{"number":"12.3","body":"L invalidite d une partie des presentes Conditions n affecte pas la validite des autres dispositions."}],"sortOrder":12}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ldc-002-01', 'ld-002', 'zh', 'Cupid Match 隐私说明', '[{"heading":"第一条 我们收集的信息","clauses":[{"number":"1.1","body":"账号信息：注册时收集的姓名、手机号或邮箱、登录密码（加密存储）。"},{"number":"1.2","body":"个人资料信息：您主动填写的婚恋资料，包括但不限于性别、出生年份、身高、所在城市、学历、行业、职业方向、婚姻状态、子女情况、交友意向、择偶偏好、生活习惯、个性特征、个人简介、标签等。"},{"number":"1.3","body":"照片与媒体：您上传的个人照片。平台可能对照片进行审核以确保符合平台规范。"},{"number":"1.4","body":"认证信息：实名认证、学历认证、婚姻状态认证时提交的身份证件、学历证明、法律文件等。"},{"number":"1.5","body":"联系方式：您的手机号、邮箱、微信号。联系方式仅用于账号安全和私人介绍成功后的双方交换，不会公开在您的资料页。"},{"number":"1.6","body":"行为数据：您在平台上的浏览记录、收藏记录、活动报名记录、私人介绍申请记录、顾问沟通记录等。"},{"number":"1.7","body":"设备信息：您访问平台时使用的设备类型、操作系统、IP 地址、浏览器类型等。"},{"number":"1.8","body":"支付信息：您购买会员时的支付凭证。平台不直接存储您的银行卡号或支付密码，支付由第三方支付服务商处理。"}],"sortOrder":1},{"heading":"第二条 信息使用方式","clauses":[{"number":"2.1","body":"平台使用您的信息用于以下目的：\\n（a）创建和管理您的账号；\\n（b）提供婚恋匹配推荐服务；\\n（c）优化推荐算法和用户体验；\\n（d）组织和协调线下活动；\\n（e）提供顾问撮合和跟进服务；\\n（f）处理您的支付和会员事务；\\n（g）保障平台安全，防范欺诈和滥用；\\n（h）遵守法律法规要求。"},{"number":"2.2","body":"平台不会使用您的个人信息进行自动化决策，导致对您产生法律效力或类似重大影响。"},{"number":"2.3","body":"平台可能对收集的信息进行匿名化或去标识化处理后，用于统计分析、服务改进和商业规划。此类处理后信息不再属于个人信息。"}],"sortOrder":2},{"heading":"第三条 信息存储与跨境传输","clauses":[{"number":"3.1","body":"您的个人信息存储在中华人民共和国境内的服务器上。"},{"number":"3.2","body":"如因服务需要将信息传输至境外，平台将按照法律法规要求进行安全评估，并取得您的单独同意。"},{"number":"3.3","body":"平台仅在实现服务目的所需的最短期限内保留您的个人信息。账号注销后，平台将在 30 日内删除或匿名化您的个人信息，法律另有规定的除外。"}],"sortOrder":3},{"heading":"第四条 信息安全保护","clauses":[{"number":"4.1","body":"平台采用行业标准的安全技术和组织措施保护您的个人信息，包括但不限于：\\n（a）数据传输采用 HTTPS/TLS 加密；\\n（b）密码采用单向哈希加盐存储；\\n（c）敏感个人信息加密存储；\\n（d）访问权限最小化原则，仅授权人员可访问必要的个人信息；\\n（e）定期安全审计和漏洞扫描。"},{"number":"4.2","body":"若发生个人信息安全事件，平台将按照法律法规要求及时告知您，并向主管部门报告。"},{"number":"4.3","body":"您应妥善保管登录凭证，避免在公共设备上保存登录状态，定期更换密码。"}],"sortOrder":4},{"heading":"第五条 信息共享与披露","clauses":[{"number":"5.1","body":"未经您明确同意，平台不会向第三方共享您的个人信息，以下情形除外：\\n（a）在您主动发起私人介绍且对方接受后，按双方确认范围交换联系方式；\\n（b）为完成支付，与第三方支付服务商共享必要的支付信息；\\n（c）法律法规要求或行政、司法机关依法提出请求；\\n（d）为保护平台、用户或公众的合法权益免受损害。"},{"number":"5.2","body":"平台与第三方服务商合作时，将通过合同要求其遵守不低于本政策标准的数据保护义务。"},{"number":"5.3","body":"除上述情形外，平台不会向任何第三方出售、出租或以其他方式提供您的个人信息。"}],"sortOrder":5},{"heading":"第六条 您的权利","clauses":[{"number":"6.1","body":"查阅权：您可以在账户设置中随时查看您提供的个人信息。"},{"number":"6.2","body":"更正权：如您的个人信息发生变化或有误，您可以在账户设置中自行修改。部分认证信息修改需经平台审核。"},{"number":"6.3","body":"删除权：您可以在账户设置中删除您的部分信息。您也可以申请注销账号，账号注销后所有个人信息将被删除或匿名化。"},{"number":"6.4","body":"导出权：您可以申请导出您在平台上的个人数据副本，平台将在 15 个工作日内处理。"},{"number":"6.5","body":"撤回同意权：您可以通过修改隐私设置撤回对特定信息使用的同意。撤回同意不影响此前基于同意的信息处理的合法性。"},{"number":"6.6","body":"投诉权：如您认为平台处理您个人信息的行为侵犯了您的合法权益，您可以向平台投诉或向监管部门举报。"}],"sortOrder":6},{"heading":"第七条 Cookie 与同类技术","clauses":[{"number":"7.1","body":"平台使用 Cookie 和类似技术来识别您的登录状态、记住您的偏好设置、分析平台使用情况。"},{"number":"7.2","body":"您可以通过浏览器设置管理或删除 Cookie。但禁用 Cookie 可能导致部分功能无法使用。"},{"number":"7.3","body":"平台可能使用第三方分析服务（如百度统计）来了解用户使用情况，这些服务可能使用自己的 Cookie。"}],"sortOrder":7},{"heading":"第八条 未成年人保护","clauses":[{"number":"8.1","body":"平台仅向年满 18 周岁的用户提供服务。"},{"number":"8.2","body":"平台不会故意收集未满 18 周岁的未成年人的个人信息。如发现误收集，将立即删除。"},{"number":"8.3","body":"如果您是父母或监护人，且发现您的未成年子女向平台提供了个人信息，请立即联系我们。"}],"sortOrder":8},{"heading":"第九条 政策更新","clauses":[{"number":"9.1","body":"平台可能根据法律法规变化或服务调整更新本隐私政策。"},{"number":"9.2","body":"更新后的政策将在平台公布。重大变更将通过站内信或邮件通知您。"},{"number":"9.3","body":"您继续使用平台服务即表示您同意更新后的隐私政策。如您不同意，应停止使用并注销账号。"}],"sortOrder":9},{"heading":"第十条 联系我们","clauses":[{"number":"10.1","body":"如您对本隐私政策有任何疑问、意见或投诉，请通过以下方式联系我们：\\n\\n邮箱：privacy@cupidmatch.com\\n地址：[平台运营方注册地址]\\n客服电话：[客服电话号码]"},{"number":"10.2","body":"我们将在收到您的请求后 15 个工作日内回复。"}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ldc-002-02', 'ld-002', 'en', 'Cupid Match Privacy Notice', '[{"heading":"Article 1 Information We Collect","clauses":[{"number":"1.1","body":"Account information: name, phone number or email address, and login password collected during registration. Passwords are stored in encrypted form."},{"number":"1.2","body":"Profile information: matchmaking profile information you voluntarily provide, including but not limited to gender, year of birth, height, city, education, industry, career direction, marital status, children-related information, relationship intention, partner preferences, lifestyle, personality traits, personal introduction, and tags."},{"number":"1.3","body":"Photos and media: personal photos uploaded by you. The Platform may review photos to ensure compliance with Platform rules."},{"number":"1.4","body":"Verification information: identity documents, education certificates, legal documents, and other materials submitted for identity, education, or marital status verification."},{"number":"1.5","body":"Contact details: your phone number, email address, and WeChat ID. Contact details are used only for account security and exchange after a successful private introduction, and will not be publicly displayed on your profile page."},{"number":"1.6","body":"Behavior data: browsing records, favorites, event registration records, private introduction request records, advisor communication records, and similar Platform activity data."},{"number":"1.7","body":"Device information: device type, operating system, IP address, browser type, and similar information when you access the Platform."},{"number":"1.8","body":"Payment information: payment proof generated when you purchase membership. The Platform does not directly store your bank card number or payment password. Payments are processed by third-party payment service providers."}],"sortOrder":1},{"heading":"Article 2 How We Use Information","clauses":[{"number":"2.1","body":"The Platform uses your information for the following purposes:\\n(a) creating and managing your account;\\n(b) providing matchmaking recommendations;\\n(c) optimizing recommendation algorithms and user experience;\\n(d) organizing and coordinating offline events;\\n(e) providing advisor matchmaking and follow-up services;\\n(f) handling payment and membership matters;\\n(g) protecting Platform security and preventing fraud and abuse;\\n(h) complying with laws and regulations."},{"number":"2.2","body":"The Platform will not use your personal information for automated decision-making that produces legal effects or similarly significant impacts on you."},{"number":"2.3","body":"The Platform may anonymize or de-identify collected information and use it for statistical analysis, service improvement, and business planning. Information processed in this way no longer constitutes personal information."}],"sortOrder":2},{"heading":"Article 3 Information Storage and Cross-Border Transfer","clauses":[{"number":"3.1","body":"Your personal information is stored on servers located within the territory of the People’s Republic of China."},{"number":"3.2","body":"If service needs require information to be transferred overseas, the Platform will conduct security assessments and obtain your separate consent in accordance with applicable laws and regulations."},{"number":"3.3","body":"The Platform retains your personal information only for the minimum period necessary to achieve the service purposes. After account cancellation, the Platform will delete or anonymize your personal information within 30 days, unless otherwise required by law."}],"sortOrder":3},{"heading":"Article 4 Information Security","clauses":[{"number":"4.1","body":"The Platform adopts industry-standard technical and organizational security measures to protect your personal information, including but not limited to:\\n(a) HTTPS/TLS encryption for data transmission;\\n(b) one-way salted hashing for password storage;\\n(c) encrypted storage of sensitive personal information;\\n(d) least-privilege access control, with only authorized personnel able to access necessary personal information;\\n(e) regular security audits and vulnerability scans."},{"number":"4.2","body":"If a personal information security incident occurs, the Platform will notify you and report to competent authorities in accordance with laws and regulations."},{"number":"4.3","body":"You should keep your login credentials secure, avoid saving login status on public devices, and change your password regularly."}],"sortOrder":4},{"heading":"Article 5 Information Sharing and Disclosure","clauses":[{"number":"5.1","body":"Without your express consent, the Platform will not share your personal information with third parties, except in the following circumstances:\\n(a) after you initiate a private introduction and the other party accepts, contact details are exchanged within the scope confirmed by both parties;\\n(b) necessary payment information is shared with third-party payment service providers to complete payment;\\n(c) laws and regulations require disclosure, or administrative or judicial authorities make lawful requests;\\n(d) disclosure is necessary to protect the lawful rights and interests of the Platform, users, or the public from harm."},{"number":"5.2","body":"When the Platform cooperates with third-party service providers, it will require them by contract to comply with data protection obligations no less protective than this policy."},{"number":"5.3","body":"Except for the circumstances above, the Platform will not sell, rent, or otherwise provide your personal information to any third party."}],"sortOrder":5},{"heading":"Article 6 Your Rights","clauses":[{"number":"6.1","body":"Right of access: You may view the personal information you provided at any time in account settings."},{"number":"6.2","body":"Right of correction: If your personal information changes or is inaccurate, you may modify it in account settings. Changes to certain verification information require Platform review."},{"number":"6.3","body":"Right of deletion: You may delete part of your information in account settings. You may also apply to cancel your account. After account cancellation, all personal information will be deleted or anonymized."},{"number":"6.4","body":"Right of export: You may request a copy of your personal data on the Platform. The Platform will process the request within 15 working days."},{"number":"6.5","body":"Right to withdraw consent: You may withdraw consent for specific information use by modifying privacy settings. Withdrawal of consent does not affect the lawfulness of information processing conducted before withdrawal."},{"number":"6.6","body":"Right to complain: If you believe the Platform’s handling of your personal information infringes your lawful rights and interests, you may file a complaint with the Platform or report to regulatory authorities."}],"sortOrder":6},{"heading":"Article 7 Cookies and Similar Technologies","clauses":[{"number":"7.1","body":"The Platform uses cookies and similar technologies to identify your login status, remember your preferences, and analyze Platform usage."},{"number":"7.2","body":"You may manage or delete cookies through browser settings. However, disabling cookies may cause some functions to become unavailable."},{"number":"7.3","body":"The Platform may use third-party analytics services, such as Baidu Analytics, to understand user usage. These services may use their own cookies."}],"sortOrder":7},{"heading":"Article 8 Protection of Minors","clauses":[{"number":"8.1","body":"The Platform provides services only to users who are at least 18 years old."},{"number":"8.2","body":"The Platform does not knowingly collect personal information from minors under 18. If such information is discovered to have been collected by mistake, it will be deleted immediately."},{"number":"8.3","body":"If you are a parent or guardian and discover that your minor child has provided personal information to the Platform, please contact us immediately."}],"sortOrder":8},{"heading":"Article 9 Policy Updates","clauses":[{"number":"9.1","body":"The Platform may update this Privacy Policy according to changes in laws and regulations or service adjustments."},{"number":"9.2","body":"The updated policy will be published on the Platform. Material changes will be notified to you by in-app message or email."},{"number":"9.3","body":"Your continued use of Platform services means that you agree to the updated Privacy Policy. If you do not agree, you should stop using the services and cancel your account."}],"sortOrder":9},{"heading":"Article 10 Contact Us","clauses":[{"number":"10.1","body":"If you have any questions, comments, or complaints about this Privacy Policy, please contact us through the following methods:\\n\\nEmail: privacy@cupidmatch.com\\nAddress: [Registered address of the Platform operator]\\nCustomer service phone: [Customer service phone number]"},{"number":"10.2","body":"We will respond within 15 working days after receiving your request."}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('ldc-002-03', 'ld-002', 'fr', 'Politique de confidentialite Cupid Match', '[{"heading":"Article 1 Informations que nous collectons","clauses":[{"number":"1.1","body":"Informations de compte : nom, numero de telephone ou adresse email, et mot de passe de connexion collectes lors de l inscription. Les mots de passe sont stockes sous forme chiffree."},{"number":"1.2","body":"Informations de profil : donnees de rencontre que vous fournissez volontairement, y compris notamment sexe, annee de naissance, taille, ville, education, secteur, orientation professionnelle, situation matrimoniale, informations relatives aux enfants, intention relationnelle, preferences de partenaire, mode de vie, traits de personnalite, presentation personnelle et etiquettes."},{"number":"1.3","body":"Photos et medias : photos personnelles que vous televersez. La Plateforme peut verifier les photos afin de garantir leur conformite aux regles de la Plateforme."},{"number":"1.4","body":"Informations de verification : documents d identite, justificatifs de diplome, documents juridiques et autres elements soumis lors de la verification d identite, d education ou de situation matrimoniale."},{"number":"1.5","body":"Coordonnees : votre numero de telephone, adresse email et identifiant WeChat. Les coordonnees servent uniquement a la securite du compte et a l echange apres une introduction privee reussie. Elles ne sont pas affichees publiquement sur votre page de profil."},{"number":"1.6","body":"Donnees comportementales : historiques de consultation, favoris, inscriptions aux evenements, demandes d introduction privee, communications avec les conseillers et donnees similaires d activite sur la Plateforme."},{"number":"1.7","body":"Informations sur l appareil : type d appareil, systeme d exploitation, adresse IP, type de navigateur et informations similaires lorsque vous accedez a la Plateforme."},{"number":"1.8","body":"Informations de paiement : justificatifs de paiement generes lors de l achat d un abonnement. La Plateforme ne stocke pas directement votre numero de carte bancaire ni votre mot de passe de paiement. Les paiements sont traites par des prestataires tiers de paiement."}],"sortOrder":1},{"heading":"Article 2 Utilisation des informations","clauses":[{"number":"2.1","body":"La Plateforme utilise vos informations aux fins suivantes :\\n(a) creer et gerer votre compte ;\\n(b) fournir des recommandations de mise en relation ;\\n(c) optimiser les algorithmes de recommandation et l experience utilisateur ;\\n(d) organiser et coordonner les evenements hors ligne ;\\n(e) fournir des services de conseil, de mise en relation et de suivi ;\\n(f) traiter les paiements et les questions d abonnement ;\\n(g) proteger la securite de la Plateforme et prevenir la fraude et les abus ;\\n(h) respecter les lois et reglements applicables."},{"number":"2.2","body":"La Plateforme n utilisera pas vos informations personnelles pour prendre des decisions automatisees produisant des effets juridiques ou des effets similaires significatifs a votre egard."},{"number":"2.3","body":"La Plateforme peut anonymiser ou de-identifier les informations collectees et les utiliser pour des analyses statistiques, l amelioration des services et la planification commerciale. Les informations ainsi traitees ne constituent plus des informations personnelles."}],"sortOrder":2},{"heading":"Article 3 Stockage et transfert transfrontalier","clauses":[{"number":"3.1","body":"Vos informations personnelles sont stockees sur des serveurs situes sur le territoire de la Republique populaire de Chine."},{"number":"3.2","body":"Si les besoins du service exigent un transfert d informations a l etranger, la Plateforme procedera aux evaluations de securite requises par les lois et reglements et obtiendra votre consentement separe."},{"number":"3.3","body":"La Plateforme conserve vos informations personnelles uniquement pendant la duree minimale necessaire a la realisation des finalites du service. Apres suppression du compte, la Plateforme supprimera ou anonymisera vos informations personnelles dans un delai de 30 jours, sauf disposition legale contraire."}],"sortOrder":3},{"heading":"Article 4 Securite des informations","clauses":[{"number":"4.1","body":"La Plateforme adopte des mesures techniques et organisationnelles conformes aux standards du secteur pour proteger vos informations personnelles, y compris notamment :\\n(a) chiffrement HTTPS/TLS pour la transmission des donnees ;\\n(b) stockage des mots de passe par hachage sale a sens unique ;\\n(c) stockage chiffre des informations personnelles sensibles ;\\n(d) controle d acces selon le principe du moindre privilege, seuls les personnels autorises pouvant acceder aux informations necessaires ;\\n(e) audits de securite et analyses de vulnerabilite reguliers."},{"number":"4.2","body":"En cas d incident de securite concernant des informations personnelles, la Plateforme vous informera et le signalera aux autorites competentes conformement aux lois et reglements."},{"number":"4.3","body":"Vous devez proteger vos identifiants de connexion, eviter de conserver une session ouverte sur un appareil public et changer regulierement votre mot de passe."}],"sortOrder":4},{"heading":"Article 5 Partage et divulgation des informations","clauses":[{"number":"5.1","body":"Sans votre consentement explicite, la Plateforme ne partagera pas vos informations personnelles avec des tiers, sauf dans les cas suivants :\\n(a) apres votre demande d introduction privee et l acceptation par l autre partie, les coordonnees sont echangees dans la limite confirmee par les deux parties ;\\n(b) les informations de paiement necessaires sont partagees avec un prestataire tiers de paiement pour finaliser le paiement ;\\n(c) la loi ou la reglementation l exige, ou une autorite administrative ou judiciaire en fait la demande legalement ;\\n(d) le partage est necessaire pour proteger les droits et interets legitimes de la Plateforme, des utilisateurs ou du public contre un dommage."},{"number":"5.2","body":"Lorsque la Plateforme coopere avec des prestataires tiers, elle leur impose contractuellement des obligations de protection des donnees au moins equivalentes a celles de la presente politique."},{"number":"5.3","body":"Sauf dans les situations ci-dessus, la Plateforme ne vendra, louera ni fournira autrement vos informations personnelles a aucun tiers."}],"sortOrder":5},{"heading":"Article 6 Vos droits","clauses":[{"number":"6.1","body":"Droit d acces : vous pouvez consulter a tout moment les informations personnelles que vous avez fournies dans les parametres du compte."},{"number":"6.2","body":"Droit de rectification : si vos informations personnelles changent ou sont inexactes, vous pouvez les modifier dans les parametres du compte. Certaines informations de verification doivent etre examinees par la Plateforme."},{"number":"6.3","body":"Droit de suppression : vous pouvez supprimer une partie de vos informations dans les parametres du compte. Vous pouvez egalement demander la suppression de votre compte. Apres suppression du compte, toutes les informations personnelles seront supprimees ou anonymisees."},{"number":"6.4","body":"Droit d exportation : vous pouvez demander une copie de vos donnees personnelles sur la Plateforme. La Plateforme traitera la demande dans un delai de 15 jours ouvrables."},{"number":"6.5","body":"Droit de retrait du consentement : vous pouvez retirer votre consentement a certaines utilisations des informations en modifiant vos parametres de confidentialite. Le retrait du consentement n affecte pas la legalite des traitements effectues avant le retrait."},{"number":"6.6","body":"Droit de plainte : si vous estimez que le traitement de vos informations personnelles par la Plateforme porte atteinte a vos droits et interets legitimes, vous pouvez deposer une plainte aupres de la Plateforme ou signaler le fait aux autorites de controle."}],"sortOrder":6},{"heading":"Article 7 Cookies et technologies similaires","clauses":[{"number":"7.1","body":"La Plateforme utilise des cookies et technologies similaires pour identifier votre etat de connexion, memoriser vos preferences et analyser l utilisation de la Plateforme."},{"number":"7.2","body":"Vous pouvez gerer ou supprimer les cookies via les parametres du navigateur. Toutefois, la desactivation des cookies peut rendre certaines fonctions indisponibles."},{"number":"7.3","body":"La Plateforme peut utiliser des services d analyse tiers, tels que Baidu Analytics, pour comprendre l utilisation par les utilisateurs. Ces services peuvent utiliser leurs propres cookies."}],"sortOrder":7},{"heading":"Article 8 Protection des mineurs","clauses":[{"number":"8.1","body":"La Plateforme fournit ses services uniquement aux utilisateurs ages d au moins 18 ans."},{"number":"8.2","body":"La Plateforme ne collecte pas sciemment les informations personnelles de mineurs de moins de 18 ans. Si une telle collecte par erreur est constatee, les informations seront supprimees immediatement."},{"number":"8.3","body":"Si vous etes parent ou tuteur et constatez que votre enfant mineur a fourni des informations personnelles a la Plateforme, veuillez nous contacter immediatement."}],"sortOrder":8},{"heading":"Article 9 Mise a jour de la politique","clauses":[{"number":"9.1","body":"La Plateforme peut mettre a jour la presente Politique de confidentialite selon les changements de lois et reglements ou les ajustements de service."},{"number":"9.2","body":"La politique mise a jour sera publiee sur la Plateforme. Les changements importants vous seront notifies par message interne ou email."},{"number":"9.3","body":"La poursuite de l utilisation des services de la Plateforme vaut acceptation de la Politique de confidentialite mise a jour. Si vous n acceptez pas, vous devez cesser d utiliser les services et supprimer votre compte."}],"sortOrder":9},{"heading":"Article 10 Nous contacter","clauses":[{"number":"10.1","body":"Pour toute question, suggestion ou plainte concernant la presente Politique de confidentialite, vous pouvez nous contacter par les moyens suivants :\\n\\nEmail : privacy@cupidmatch.com\\nAdresse : [Adresse d enregistrement de l operateur de la Plateforme]\\nTelephone du service client : [Numero du service client]"},{"number":"10.2","body":"Nous repondrons dans un delai de 15 jours ouvrables apres reception de votre demande."}],"sortOrder":10}]', '2026-01-01 00:00:00', '2026-01-01 00:00:00');


insert into cm_user_agreement_acceptances (id, user_id, document_type, document_version, accepted_at, created_at) values
  ('ua-001', 'u-001', 'terms', '1.0', '2026-05-15 22:13:49', '2026-05-15 22:13:49'),
  ('ua-002', 'u-001', 'privacy', '1.0', '2026-05-15 22:13:49', '2026-05-15 22:13:49');


insert into cm_profiles (id, profile_type, gender, birth_year, height, city_code, country_code, nationality_code, profile_status, last_active_at, family_visible, degree_level, education_code, industry_code, marital_status, has_children, children_plan, accepts_long_distance, dating_intention_code, relocation, preferred_age_min, preferred_age_max, preferred_location, smoking, drinking, activity_level, weekend_style, pets, communication_style, archived_at, created_at, updated_at) values
  ('p-001', 'self', 'female', 1995, 168, 'paris', 'france', 'french', 'open', '2026-04-20 18:30:00', 0, 'master', 'master', 'luxury', 'never_married', 0, 'wants', 1, 'serious', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('p-002', 'self', 'male', 1992, 178, 'paris', 'france', 'chinese', 'open', '2026-04-22 09:00:00', 1, 'master', 'master', 'technology', 'never_married', 0, 'wants', 1, 'marriage', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('p-006', 'self', 'female', 1990, 170, 'paris', 'france', 'french', 'review', '2026-04-21 20:30:00', 1, 'phd', 'phd', 'public_affairs', 'divorced', 1, 'does_not_want', 1, 'exclusive', 'willing', 28, 40, 'regional', 'never', 'social', 'low', 'flexible', 'likes', 'direct', null, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('p-009', 'self', 'male', 1991, 174, 'geneva', 'switzerland', 'swiss', 'open', '2026-04-25 07:50:00', 1, 'master', 'master', 'finance', 'never_married', 0, 'wants', 1, 'cross_border', 'willing', 28, 40, 'regional', 'never', 'social', 'high', 'flexible', 'likes', 'direct', null, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('p-010', 'self', 'female', 1993, 171, 'amsterdam', 'netherlands', 'dutch', 'open', '2026-04-21 10:45:00', 1, 'master', 'master', 'digital_product', 'divorced', 0, 'wants', 1, 'serious', 'willing', 28, 40, 'regional', 'never', 'social', 'moderate', 'flexible', 'likes', 'direct', null, '2026-02-14 00:00:00', '2026-04-21 10:45:00');


insert into cm_profile_languages (profile_id, language_code) values
  ('p-001', 'FR'),
  ('p-001', 'EN'),
  ('p-002', 'ZH'),
  ('p-002', 'FR'),
  ('p-002', 'EN'),
  ('p-006', 'FR'),
  ('p-006', 'EN'),
  ('p-009', 'FR'),
  ('p-009', 'EN'),
  ('p-009', 'DE'),
  ('p-010', 'EN'),
  ('p-010', 'NL'),
  ('p-010', 'FR');


insert into cm_profile_relationship_values (profile_id, value_code) values
  ('p-001', 'honesty'),
  ('p-001', 'growth'),
  ('p-002', 'loyalty'),
  ('p-002', 'support'),
  ('p-006', 'respect'),
  ('p-006', 'communication'),
  ('p-009', 'family'),
  ('p-009', 'trust'),
  ('p-010', 'respect'),
  ('p-010', 'communication');


insert into cm_profile_localized_fields (id, profile_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('plf-00001', 'p-001', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00002', 'p-001', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00003', 'p-001', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00004', 'p-001', 'city', 'zh', '巴黎', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00005', 'p-001', 'city', 'fr', 'Paris', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00006', 'p-001', 'city', 'en', 'Paris', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00007', 'p-001', 'country', 'zh', '法国', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00008', 'p-001', 'country', 'fr', 'France', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00009', 'p-001', 'country', 'en', 'France', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00010', 'p-001', 'nationality', 'zh', '法国', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00011', 'p-001', 'nationality', 'fr', 'Francaise', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00012', 'p-001', 'nationality', 'en', 'French', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00013', 'p-001', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00014', 'p-001', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00015', 'p-001', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00016', 'p-001', 'industry', 'zh', '奢侈品', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00017', 'p-001', 'industry', 'fr', 'Luxe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00018', 'p-001', 'industry', 'en', 'Luxury', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00019', 'p-001', 'career_direction', 'zh', '品牌策略', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00020', 'p-001', 'career_direction', 'fr', 'Strategie de marque', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00021', 'p-001', 'career_direction', 'en', 'Brand strategist', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00022', 'p-001', 'relationship_goal', 'zh', '一年内确认节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00023', 'p-001', 'relationship_goal', 'fr', 'Clarifier le rythme sous un an', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00024', 'p-001', 'relationship_goal', 'en', 'Clarify long-term pace within a year', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00025', 'p-001', 'residence_plan', 'zh', '优先巴黎，也接受欧洲双城', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00026', 'p-001', 'residence_plan', 'fr', 'Paris en priorite, ouverte a une double ville en Europe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00027', 'p-001', 'residence_plan', 'en', 'Prefers Paris, open to a two-city setup in Europe', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00028', 'p-001', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00029', 'p-001', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00030', 'p-001', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00031', 'p-001', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00032', 'p-001', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00033', 'p-001', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00034', 'p-001', 'exercise', 'zh', '每周瑜伽和步行', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00035', 'p-001', 'exercise', 'fr', 'Yoga et marche chaque semaine', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00036', 'p-001', 'exercise', 'en', 'Weekly yoga and walking', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00037', 'p-001', 'summary', 'zh', '重视表达、节奏和跨文化理解。', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00038', 'p-001', 'summary', 'fr', 'Attentive a la communication, au rythme et a la comprehension interculturelle.', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00039', 'p-001', 'summary', 'en', 'Values communication, pacing, and intercultural understanding.', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00040', 'p-002', 'profile_name', 'zh', 'Lin', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00041', 'p-002', 'profile_name', 'fr', 'Profile Lin', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00042', 'p-002', 'profile_name', 'en', 'Lin profile', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00043', 'p-002', 'city', 'zh', '巴黎', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00044', 'p-002', 'city', 'fr', 'Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00045', 'p-002', 'city', 'en', 'Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00046', 'p-002', 'country', 'zh', '法国', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00047', 'p-002', 'country', 'fr', 'France', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00048', 'p-002', 'country', 'en', 'France', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00049', 'p-002', 'nationality', 'zh', '中国', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00050', 'p-002', 'nationality', 'fr', 'Chinoise', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00051', 'p-002', 'nationality', 'en', 'Chinese', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00052', 'p-002', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00053', 'p-002', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00054', 'p-002', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00055', 'p-002', 'industry', 'zh', '科技', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00056', 'p-002', 'industry', 'fr', 'Tech', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00057', 'p-002', 'industry', 'en', 'Technology', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00058', 'p-002', 'career_direction', 'zh', '产品负责人', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00059', 'p-002', 'career_direction', 'fr', 'Responsable produit', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00060', 'p-002', 'career_direction', 'en', 'Product lead', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00061', 'p-002', 'relationship_goal', 'zh', '明确方向后稳步推进', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00062', 'p-002', 'relationship_goal', 'fr', 'Avancer de facon stable une fois l orientation clarifiee', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00063', 'p-002', 'relationship_goal', 'en', 'Move steadily once long-term direction is clear', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00064', 'p-002', 'residence_plan', 'zh', '巴黎长期发展', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00065', 'p-002', 'residence_plan', 'fr', 'Projet long terme a Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00066', 'p-002', 'residence_plan', 'en', 'Long-term plan in Paris', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00067', 'p-002', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00068', 'p-002', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00069', 'p-002', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00070', 'p-002', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00071', 'p-002', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00072', 'p-002', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00073', 'p-002', 'exercise', 'zh', '跑步和力量训练', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00074', 'p-002', 'exercise', 'fr', 'Course et renforcement', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00075', 'p-002', 'exercise', 'en', 'Running and strength training', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00076', 'p-002', 'summary', 'zh', '重视长期关系中的稳定、透明和行动力。', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('plf-00077', 'p-002', 'summary', 'fr', 'Cherche de la stabilite, de la clarte et de l action dans une relation durable.', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00078', 'p-002', 'summary', 'en', 'Values stability, clarity, and follow-through in a long-term relationship.', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00079', 'p-006', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00080', 'p-006', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00081', 'p-006', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00082', 'p-006', 'city', 'zh', '巴黎', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00083', 'p-006', 'city', 'fr', 'Paris', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00084', 'p-006', 'city', 'en', 'Paris', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00085', 'p-006', 'country', 'zh', '法国', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00086', 'p-006', 'country', 'fr', 'France', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00087', 'p-006', 'country', 'en', 'France', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00088', 'p-006', 'nationality', 'zh', '法国', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00089', 'p-006', 'nationality', 'fr', 'Francaise', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00090', 'p-006', 'nationality', 'en', 'French', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00091', 'p-006', 'education', 'zh', '博士', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00092', 'p-006', 'education', 'fr', 'Doctorat', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00093', 'p-006', 'education', 'en', 'PhD', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00094', 'p-006', 'industry', 'zh', '公共事务', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00095', 'p-006', 'industry', 'fr', 'Affaires publiques', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00096', 'p-006', 'industry', 'en', 'Public affairs', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00097', 'p-006', 'career_direction', 'zh', '公共政策研究员', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00098', 'p-006', 'career_direction', 'fr', 'Chercheuse en politiques publiques', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00099', 'p-006', 'career_direction', 'en', 'Public policy researcher', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00100', 'p-006', 'relationship_goal', 'zh', '先确认家庭节奏与城市安排', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00101', 'p-006', 'relationship_goal', 'fr', 'Verifier d abord le rythme familial et la logistique des villes', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00102', 'p-006', 'relationship_goal', 'en', 'First confirm family rhythm and city logistics', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00103', 'p-006', 'residence_plan', 'zh', '巴黎为主，也可双城', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00104', 'p-006', 'residence_plan', 'fr', 'Paris prioritaire, possible double ville', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00105', 'p-006', 'residence_plan', 'en', 'Paris first, open to a two-city setup', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00106', 'p-006', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00107', 'p-006', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00108', 'p-006', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00109', 'p-006', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00110', 'p-006', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00111', 'p-006', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00112', 'p-006', 'exercise', 'zh', '步行和网球', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00113', 'p-006', 'exercise', 'fr', 'Marche et tennis', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00114', 'p-006', 'exercise', 'en', 'Walking and tennis', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00115', 'p-006', 'summary', 'zh', '希望在成熟、清晰和尊重边界的前提下推进关系。', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00116', 'p-006', 'summary', 'fr', 'Souhaite avancer dans un cadre mature, clair et respectueux des limites.', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00117', 'p-006', 'summary', 'en', 'Wants to move forward in a mature, clear, and boundary-respecting way.', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00118', 'p-009', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00119', 'p-009', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00120', 'p-009', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00121', 'p-009', 'city', 'zh', '日内瓦', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00122', 'p-009', 'city', 'fr', 'Geneve', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00123', 'p-009', 'city', 'en', 'Geneva', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00124', 'p-009', 'country', 'zh', '瑞士', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00125', 'p-009', 'country', 'fr', 'Suisse', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00126', 'p-009', 'country', 'en', 'Switzerland', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00127', 'p-009', 'nationality', 'zh', '瑞士', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00128', 'p-009', 'nationality', 'fr', 'Suisse', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00129', 'p-009', 'nationality', 'en', 'Swiss', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00130', 'p-009', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00131', 'p-009', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00132', 'p-009', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00133', 'p-009', 'industry', 'zh', '金融', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00134', 'p-009', 'industry', 'fr', 'Finance', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00135', 'p-009', 'industry', 'en', 'Finance', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00136', 'p-009', 'career_direction', 'zh', '投融资经理', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00137', 'p-009', 'career_direction', 'fr', 'Manager financement', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00138', 'p-009', 'career_direction', 'en', 'Finance manager', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00139', 'p-009', 'relationship_goal', 'zh', '接受跨境安排，优先确定共同城市策略', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00140', 'p-009', 'relationship_goal', 'fr', 'Ouvert au transfrontalier avec strategie de ville commune', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00141', 'p-009', 'relationship_goal', 'en', 'Open to cross-border setup with a shared city strategy', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00142', 'p-009', 'residence_plan', 'zh', '日内瓦为主，接受巴黎双城', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00143', 'p-009', 'residence_plan', 'fr', 'Geneve en base, possible schema Geneve-Paris', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00144', 'p-009', 'residence_plan', 'en', 'Geneva-based, open to Geneva-Paris setup', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00145', 'p-009', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00146', 'p-009', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00147', 'p-009', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00148', 'p-009', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00149', 'p-009', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00150', 'p-009', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00151', 'p-009', 'exercise', 'zh', '滑雪和徒步', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00152', 'p-009', 'exercise', 'fr', 'Ski et randonnee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00153', 'p-009', 'exercise', 'en', 'Skiing and hiking', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00154', 'p-009', 'summary', 'zh', '重视跨城市协同能力和长期执行力。', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00155', 'p-009', 'summary', 'fr', 'Valorise la coordination entre villes et la capacite d execution.', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00156', 'p-009', 'summary', 'en', 'Values cross-city coordination and long-term execution.', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00157', 'p-010', 'profile_name', 'zh', '', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00158', 'p-010', 'profile_name', 'fr', '', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00159', 'p-010', 'profile_name', 'en', '', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-24 00:00:00'),
  ('plf-00160', 'p-010', 'city', 'zh', '阿姆斯特丹', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00161', 'p-010', 'city', 'fr', 'Amsterdam', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00162', 'p-010', 'city', 'en', 'Amsterdam', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00163', 'p-010', 'country', 'zh', '荷兰', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00164', 'p-010', 'country', 'fr', 'Pays-Bas', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00165', 'p-010', 'country', 'en', 'Netherlands', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00166', 'p-010', 'nationality', 'zh', '荷兰', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00167', 'p-010', 'nationality', 'fr', 'Neerlandaise', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00168', 'p-010', 'nationality', 'en', 'Dutch', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00169', 'p-010', 'education', 'zh', '硕士', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00170', 'p-010', 'education', 'fr', 'Master', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00171', 'p-010', 'education', 'en', 'Master', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00172', 'p-010', 'industry', 'zh', '数字产品', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00173', 'p-010', 'industry', 'fr', 'Produit numerique', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00174', 'p-010', 'industry', 'en', 'Digital product', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00175', 'p-010', 'career_direction', 'zh', '用户研究员', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00176', 'p-010', 'career_direction', 'fr', 'Chercheuse UX', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00177', 'p-010', 'career_direction', 'en', 'UX researcher', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00178', 'p-010', 'relationship_goal', 'zh', '先建立共同生活节奏，再推进长期关系', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00179', 'p-010', 'relationship_goal', 'fr', 'Installer un rythme de vie commun avant de projeter le long terme', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00180', 'p-010', 'relationship_goal', 'en', 'Build daily-life rhythm first, then advance long-term plans', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00181', 'p-010', 'residence_plan', 'zh', '阿姆斯特丹为主，接受巴黎/布鲁塞尔协同', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00182', 'p-010', 'residence_plan', 'fr', 'Base Amsterdam, ouverte a Paris ou Bruxelles', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00183', 'p-010', 'residence_plan', 'en', 'Amsterdam-based, open to Paris/Brussels coordination', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00184', 'p-010', 'preferred_education', 'zh', '本科及以上，更看重学习能力和沟通方式', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00185', 'p-010', 'preferred_education', 'fr', 'Licence ou plus, avec attention a la curiosite et a la communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00186', 'p-010', 'preferred_education', 'en', 'Bachelor or above, with more weight on curiosity and communication style', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00187', 'p-010', 'family_life', 'zh', '希望在稳定关系中自然讨论婚育节奏', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00188', 'p-010', 'family_life', 'fr', 'Souhaite discuter du rythme familial dans une relation stable', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00189', 'p-010', 'family_life', 'en', 'Wants to discuss family plans naturally within a stable relationship', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00190', 'p-010', 'exercise', 'zh', '划船和慢跑', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00191', 'p-010', 'exercise', 'fr', 'Rameur et jogging', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00192', 'p-010', 'exercise', 'en', 'Rowing and jogging', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00193', 'p-010', 'summary', 'zh', '重视生活一致性与沟通质量。', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00194', 'p-010', 'summary', 'fr', 'Attachee a la coherence de vie et a la qualite de communication.', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('plf-00195', 'p-010', 'summary', 'en', 'Values lifestyle consistency and communication quality.', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');


insert into cm_profile_localized_items (id, profile_id, field_name, item_order, locale, value, source, provider, status, created_at, updated_at) values
  ('pli-00001', 'p-001', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00002', 'p-001', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00003', 'p-001', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00004', 'p-001', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00005', 'p-001', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00006', 'p-001', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00007', 'p-001', 'personality_traits', 0, 'zh', '表达清晰', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00008', 'p-001', 'personality_traits', 0, 'fr', 'Communication claire', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00009', 'p-001', 'personality_traits', 0, 'en', 'Clear communicator', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00010', 'p-001', 'personality_traits', 1, 'zh', '审美稳定', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00011', 'p-001', 'personality_traits', 1, 'fr', 'Sens esthetique stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00012', 'p-001', 'personality_traits', 1, 'en', 'Consistent taste', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00013', 'p-001', 'personality_traits', 2, 'zh', '重视边界', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00014', 'p-001', 'personality_traits', 2, 'fr', 'Respecte les limites', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00015', 'p-001', 'personality_traits', 2, 'en', 'Values boundaries', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00016', 'p-001', 'interests', 0, 'zh', '展览', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00017', 'p-001', 'interests', 0, 'fr', 'Expositions', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00018', 'p-001', 'interests', 0, 'en', 'Exhibitions', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00019', 'p-001', 'interests', 1, 'zh', '城市散步', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00020', 'p-001', 'interests', 1, 'fr', 'Balades urbaines', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00021', 'p-001', 'interests', 1, 'en', 'City walks', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00022', 'p-001', 'interests', 2, 'zh', '法式烹饪', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00023', 'p-001', 'interests', 2, 'fr', 'Cuisine francaise', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00024', 'p-001', 'interests', 2, 'en', 'French cooking', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00025', 'p-001', 'tags', 0, 'zh', '文化活动', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00026', 'p-001', 'tags', 0, 'fr', 'Activites culturelles', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00027', 'p-001', 'tags', 0, 'en', 'Cultural activities', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00028', 'p-001', 'tags', 1, 'zh', '城市生活', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00029', 'p-001', 'tags', 1, 'fr', 'Vie urbaine', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00030', 'p-001', 'tags', 1, 'en', 'City life', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00031', 'p-001', 'tags', 2, 'zh', '稳定节奏', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00032', 'p-001', 'tags', 2, 'fr', 'Rythme stable', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00033', 'p-001', 'tags', 2, 'en', 'Steady pace', 'manual', 'human', 'ready', '2026-01-12 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00034', 'p-002', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00035', 'p-002', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00036', 'p-002', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00037', 'p-002', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00038', 'p-002', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00039', 'p-002', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00040', 'p-002', 'personality_traits', 0, 'zh', '目标清晰', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00041', 'p-002', 'personality_traits', 0, 'fr', 'Objectifs clairs', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00042', 'p-002', 'personality_traits', 0, 'en', 'Clear goals', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00043', 'p-002', 'personality_traits', 1, 'zh', '执行力强', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00044', 'p-002', 'personality_traits', 1, 'fr', 'Fort sens de l execution', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00045', 'p-002', 'personality_traits', 1, 'en', 'Strong follow-through', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00046', 'p-002', 'personality_traits', 2, 'zh', '情绪稳定', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00047', 'p-002', 'personality_traits', 2, 'fr', 'Stable emotionnellement', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00048', 'p-002', 'personality_traits', 2, 'en', 'Emotionally steady', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00049', 'p-002', 'interests', 0, 'zh', '骑行', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00050', 'p-002', 'interests', 0, 'fr', 'Velo', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00051', 'p-002', 'interests', 0, 'en', 'Cycling', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00052', 'p-002', 'interests', 1, 'zh', '产品播客', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00053', 'p-002', 'interests', 1, 'fr', 'Podcasts produit', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00054', 'p-002', 'interests', 1, 'en', 'Product podcasts', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00055', 'p-002', 'interests', 2, 'zh', '周末做饭', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00056', 'p-002', 'interests', 2, 'fr', 'Cuisine le week-end', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00057', 'p-002', 'interests', 2, 'en', 'Weekend cooking', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00058', 'p-002', 'tags', 0, 'zh', '长期关系', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00059', 'p-002', 'tags', 0, 'fr', 'Long terme', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00060', 'p-002', 'tags', 0, 'en', 'Long-term', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00061', 'p-002', 'tags', 1, 'zh', '顾问协同', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00062', 'p-002', 'tags', 1, 'fr', 'Coordination conseiller', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00063', 'p-002', 'tags', 1, 'en', 'Advisor-supported', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00064', 'p-002', 'tags', 2, 'zh', '跨文化', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('pli-00065', 'p-002', 'tags', 2, 'fr', 'Interculturel', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00066', 'p-002', 'tags', 2, 'en', 'Cross-cultural', 'manual', 'human', 'ready', '2026-01-18 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00067', 'p-006', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00068', 'p-006', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00069', 'p-006', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00070', 'p-006', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00071', 'p-006', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00072', 'p-006', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00073', 'p-006', 'personality_traits', 0, 'zh', '温和直接', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00074', 'p-006', 'personality_traits', 0, 'fr', 'Douce et directe', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00075', 'p-006', 'personality_traits', 0, 'en', 'Warm and direct', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00076', 'p-006', 'personality_traits', 1, 'zh', '生活有秩序', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00077', 'p-006', 'personality_traits', 1, 'fr', 'Vie bien organisee', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00078', 'p-006', 'personality_traits', 1, 'en', 'Well organized', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00079', 'p-006', 'personality_traits', 2, 'zh', '重视真实相处', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00080', 'p-006', 'personality_traits', 2, 'fr', 'Valorise l authenticite', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00081', 'p-006', 'personality_traits', 2, 'en', 'Values authenticity', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00082', 'p-006', 'interests', 0, 'zh', '阅读', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00083', 'p-006', 'interests', 0, 'fr', 'Lecture', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00084', 'p-006', 'interests', 0, 'en', 'Reading', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00085', 'p-006', 'interests', 1, 'zh', '散步', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00086', 'p-006', 'interests', 1, 'fr', 'Balades', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00087', 'p-006', 'interests', 1, 'en', 'Walks', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00088', 'p-006', 'interests', 2, 'zh', '周末探店', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00089', 'p-006', 'interests', 2, 'fr', 'Decouvertes le week-end', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00090', 'p-006', 'interests', 2, 'en', 'Weekend discoveries', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00091', 'p-006', 'tags', 0, 'zh', '家庭节奏', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00092', 'p-006', 'tags', 0, 'fr', 'Rythme familial', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00093', 'p-006', 'tags', 0, 'en', 'Family rhythm', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00094', 'p-006', 'tags', 1, 'zh', '双城安排', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00095', 'p-006', 'tags', 1, 'fr', 'Deux villes', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00096', 'p-006', 'tags', 1, 'en', 'Two-city setup', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00097', 'p-006', 'tags', 2, 'zh', '成熟沟通', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00098', 'p-006', 'tags', 2, 'fr', 'Communication mature', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00099', 'p-006', 'tags', 2, 'en', 'Mature communication', 'manual', 'human', 'ready', '2026-03-01 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00100', 'p-009', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00101', 'p-009', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00102', 'p-009', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00103', 'p-009', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00104', 'p-009', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00105', 'p-009', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00106', 'p-009', 'personality_traits', 0, 'zh', '时间观念强', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00107', 'p-009', 'personality_traits', 0, 'fr', 'Tres ponctuel', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00108', 'p-009', 'personality_traits', 0, 'en', 'Very punctual', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00109', 'p-009', 'personality_traits', 1, 'zh', '跨文化适应力好', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00110', 'p-009', 'personality_traits', 1, 'fr', 'Aisance interculturelle', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00111', 'p-009', 'personality_traits', 1, 'en', 'Cross-cultural ease', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00112', 'p-009', 'personality_traits', 2, 'zh', '重视承诺', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00113', 'p-009', 'personality_traits', 2, 'fr', 'Attache aux engagements', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00114', 'p-009', 'personality_traits', 2, 'en', 'Commitment-minded', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00115', 'p-009', 'interests', 0, 'zh', '滑雪', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00116', 'p-009', 'interests', 0, 'fr', 'Ski', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00117', 'p-009', 'interests', 0, 'en', 'Skiing', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00118', 'p-009', 'interests', 1, 'zh', '徒步', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00119', 'p-009', 'interests', 1, 'fr', 'Randonnee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00120', 'p-009', 'interests', 1, 'en', 'Hiking', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00121', 'p-009', 'interests', 2, 'zh', '城市短途旅行', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00122', 'p-009', 'interests', 2, 'fr', 'Escapades urbaines', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00123', 'p-009', 'interests', 2, 'en', 'City breaks', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00124', 'p-009', 'tags', 0, 'zh', '跨境节奏', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00125', 'p-009', 'tags', 0, 'fr', 'Transfrontalier', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00126', 'p-009', 'tags', 0, 'en', 'Cross-border', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00127', 'p-009', 'tags', 1, 'zh', '高匹配意愿', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00128', 'p-009', 'tags', 1, 'fr', 'Intention elevee', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00129', 'p-009', 'tags', 1, 'en', 'High matching intent', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00130', 'p-009', 'tags', 2, 'zh', '执行力', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00131', 'p-009', 'tags', 2, 'fr', 'Execution', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00132', 'p-009', 'tags', 2, 'en', 'Execution', 'manual', 'human', 'ready', '2026-02-02 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00133', 'p-010', 'deal_breakers', 0, 'zh', '长期失联', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00134', 'p-010', 'deal_breakers', 0, 'fr', 'Absence prolongee de communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00135', 'p-010', 'deal_breakers', 0, 'en', 'Long periods without communication', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00136', 'p-010', 'deal_breakers', 1, 'zh', '关系目标不清晰', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00137', 'p-010', 'deal_breakers', 1, 'fr', 'Objectif relationnel flou', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00138', 'p-010', 'deal_breakers', 1, 'en', 'Unclear relationship goals', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00139', 'p-010', 'personality_traits', 0, 'zh', '温和直接', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00140', 'p-010', 'personality_traits', 0, 'fr', 'Douce et directe', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00141', 'p-010', 'personality_traits', 0, 'en', 'Warm and direct', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00142', 'p-010', 'personality_traits', 1, 'zh', '生活有秩序', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00143', 'p-010', 'personality_traits', 1, 'fr', 'Vie bien organisee', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00144', 'p-010', 'personality_traits', 1, 'en', 'Well organized', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00145', 'p-010', 'personality_traits', 2, 'zh', '重视真实相处', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00146', 'p-010', 'personality_traits', 2, 'fr', 'Valorise l authenticite', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00147', 'p-010', 'personality_traits', 2, 'en', 'Values authenticity', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00148', 'p-010', 'interests', 0, 'zh', '阅读', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00149', 'p-010', 'interests', 0, 'fr', 'Lecture', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00150', 'p-010', 'interests', 0, 'en', 'Reading', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00151', 'p-010', 'interests', 1, 'zh', '散步', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00152', 'p-010', 'interests', 1, 'fr', 'Balades', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00153', 'p-010', 'interests', 1, 'en', 'Walks', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00154', 'p-010', 'interests', 2, 'zh', '周末探店', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00155', 'p-010', 'interests', 2, 'fr', 'Decouvertes le week-end', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00156', 'p-010', 'interests', 2, 'en', 'Weekend discoveries', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00157', 'p-010', 'tags', 0, 'zh', '跨文化', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00158', 'p-010', 'tags', 0, 'fr', 'Interculturel', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00159', 'p-010', 'tags', 0, 'en', 'Cross-cultural', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00160', 'p-010', 'tags', 1, 'zh', '沟通质量', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00161', 'p-010', 'tags', 1, 'fr', 'Qualite echange', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00162', 'p-010', 'tags', 1, 'en', 'Communication quality', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00163', 'p-010', 'tags', 2, 'zh', '生活一致', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00164', 'p-010', 'tags', 2, 'fr', 'Cohérence de vie', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20'),
  ('pli-00165', 'p-010', 'tags', 2, 'en', 'Lifestyle alignment', 'manual', 'human', 'ready', '2026-02-14 00:00:00', '2026-05-18 12:07:20');


insert into cm_profile_photos (id, profile_id, url, is_primary, sort_order, status, created_at, updated_at) values
  ('p-001-photo-1', 'p-001', 'https://picsum.photos/seed/p-001-1/900/1200', 1, 1, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('p-001-photo-2', 'p-001', 'https://picsum.photos/seed/p-001-2/900/1200', 0, 2, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('p-001-photo-3', 'p-001', 'https://picsum.photos/seed/p-001-3/900/1200', 0, 3, 'approved', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('p-002-photo-1', 'p-002', 'https://picsum.photos/seed/p-002-1/900/1200', 1, 1, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('p-002-photo-2', 'p-002', 'https://picsum.photos/seed/p-002-2/900/1200', 0, 2, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('p-002-photo-3', 'p-002', 'https://picsum.photos/seed/p-002-3/900/1200', 0, 3, 'approved', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('p-006-photo-1', 'p-006', 'https://picsum.photos/seed/p-006-1/900/1200', 1, 1, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('p-006-photo-2', 'p-006', 'https://picsum.photos/seed/p-006-2/900/1200', 0, 2, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('p-006-photo-3', 'p-006', 'https://picsum.photos/seed/p-006-3/900/1200', 0, 3, 'approved', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('p-009-photo-1', 'p-009', 'https://picsum.photos/seed/p-009-1/900/1200', 1, 1, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('p-009-photo-2', 'p-009', 'https://picsum.photos/seed/p-009-2/900/1200', 0, 2, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('p-009-photo-3', 'p-009', 'https://picsum.photos/seed/p-009-3/900/1200', 0, 3, 'approved', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('p-010-photo-1', 'p-010', 'https://picsum.photos/seed/p-010-1/900/1200', 1, 1, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00'),
  ('p-010-photo-2', 'p-010', 'https://picsum.photos/seed/p-010-2/900/1200', 0, 2, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00'),
  ('p-010-photo-3', 'p-010', 'https://picsum.photos/seed/p-010-3/900/1200', 0, 3, 'approved', '2026-02-14 00:00:00', '2026-04-21 10:45:00');


insert into cm_profile_ownerships (id, user_id, profile_id, relationship_to_profile, permission, status, invited_by_user_id, accepted_at, revoked_at, created_at, updated_at) values
  ('ownership-001', 'u-001', 'p-002', 'self', 'owner', 'active', null, null, null, '2026-01-01 00:00:00', '2026-05-25 21:07:58');


insert into cm_profile_internal_records (id, profile_id, is_featured, source, updated_by_user_id, created_at, updated_at) values
  ('internal-001', 'p-001', 0, null, null, '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('internal-002', 'p-002', 1, null, null, '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('internal-006', 'p-006', 0, null, null, '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('internal-009', 'p-009', 1, null, null, '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('internal-010', 'p-010', 0, null, null, '2026-02-14 00:00:00', '2026-04-21 10:45:00');


insert into cm_profile_verifications (id, profile_id, legal_name, date_of_birth, identity_status, education_status, income_status, marital_status, review_status, verified_at, verified_by_user_id, created_at, updated_at) values
  ('verification-p-001', 'p-001', 'Aline M.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'u-001', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('verification-p-002', 'p-002', 'Lin S.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'u-001', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('verification-p-006', 'p-006', 'Sophie L.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'u-001', '2026-03-01 00:00:00', '2026-04-21 20:30:00'),
  ('verification-p-009', 'p-009', 'Martin K.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'u-001', '2026-02-02 00:00:00', '2026-04-25 07:50:00'),
  ('verification-p-010', 'p-010', 'Iris N.', null, 'verified', 'verified', 'verified', 'verified', 'approved', '2026-04-20 18:30:00', 'u-001', '2026-02-14 00:00:00', '2026-04-21 10:45:00');


insert into cm_profile_contacts (id, profile_id, phone, email, wechat, preferred_channel, visibility, created_at, updated_at) values
  ('contact-p-001', 'p-001', '+33 6 12 34 56 78', 'aline.m@example.com', null, 'phone', 'after_introduction', '2026-01-12 00:00:00', '2026-04-20 18:30:00'),
  ('contact-p-002', 'p-002', '+33 6 98 76 54 32', 'loic.d@example.com', 'loic_dubois', 'phone', 'after_introduction', '2026-01-18 00:00:00', '2026-05-25 21:07:58'),
  ('contact-p-006', 'p-006', '+33 6 11 22 33 44', 'camille.m@example.com', 'camille_martin', 'email', 'after_introduction', '2026-02-14 00:00:00', '2026-05-28 10:00:00');


insert into cm_profile_privacy_preferences (id, profile_id, hide_marital_status, hide_has_children, hide_children_plan, hide_accepts_long_distance, hide_smoking, hide_drinking, created_at, updated_at) values
  ('privacy-001', 'p-002', 0, 0, 0, 0, 0, 0, '2026-05-23 11:02:04', '2026-05-23 11:02:33');


insert into cm_membership_plans (id, tier, price_cents, currency, billing_period, private_introduction_quota, private_introduction_period, event_priority_enabled, staff_review_enabled, profile_detail_access_level, staff_support_level, concierge_priority, featured, sort_order, is_active, created_at, updated_at) values
  ('plan-free', 'free', 0, 'EUR', 'monthly', 0, 'monthly', 0, 0, 'registered', 'none', 0, 0, 1, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('plan-silver', 'silver', 2999, 'EUR', 'monthly', 5, 'monthly', 1, 1, 'registered', 'standard', 0, 1, 2, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('plan-gold', 'gold', 7999, 'EUR', 'monthly', 15, 'monthly', 1, 1, 'premium', 'priority', 1, 1, 3, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00'),
  ('plan-diamond', 'diamond', 14999, 'EUR', 'monthly', 30, 'monthly', 1, 1, 'premium', 'concierge', 1, 1, 4, 1, '2026-01-01 00:00:00', '2026-01-01 00:00:00');


insert into cm_membership_plan_localized_fields (id, plan_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('mplf-00001', 'plan-free', 'name', 'zh', '免费会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00002', 'plan-free', 'name', 'fr', 'Gratuit', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00003', 'plan-free', 'name', 'en', 'Free', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00004', 'plan-free', 'description', 'zh', '基础浏览和匹配功能', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00005', 'plan-free', 'description', 'fr', 'Consultation et matching de base', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00006', 'plan-free', 'description', 'en', 'Basic browsing and matching', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00007', 'plan-silver', 'name', 'zh', '银卡会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00008', 'plan-silver', 'name', 'fr', 'Argent', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00009', 'plan-silver', 'name', 'en', 'Silver', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00010', 'plan-silver', 'description', 'zh', '更多介绍额度和优先活动报名', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00011', 'plan-silver', 'description', 'fr', 'Plus de quotas et priorite evenements', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00012', 'plan-silver', 'description', 'en', 'More introduction quota and priority event registration', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00013', 'plan-gold', 'name', 'zh', '金卡会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00014', 'plan-gold', 'name', 'fr', 'Or', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00015', 'plan-gold', 'name', 'en', 'Gold', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00016', 'plan-gold', 'description', 'zh', '专属顾问和更多可见性', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00017', 'plan-gold', 'description', 'fr', 'Conseiller dedie et visibilite accrue', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00018', 'plan-gold', 'description', 'en', 'Dedicated advisor and enhanced visibility', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00019', 'plan-diamond', 'name', 'zh', '钻石会员', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00020', 'plan-diamond', 'name', 'fr', 'Diamant', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00021', 'plan-diamond', 'name', 'en', 'Diamond', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00022', 'plan-diamond', 'description', 'zh', '顶级服务和无限介绍额度', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00023', 'plan-diamond', 'description', 'fr', 'Service premium et quotas illimites', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20'),
  ('mplf-00024', 'plan-diamond', 'description', 'en', 'Premium service and unlimited introductions', 'manual', 'human', 'ready', '2026-01-01 00:00:00', '2026-05-18 12:07:20');


insert into cm_user_memberships (id, user_id, plan_id, tier, status, started_at, expires_at, created_at, updated_at) values
  ('user-membership-001', 'u-001', 'plan-gold', 'gold', 'active', '2026-01-18 00:00:00', null, '2026-01-18 00:00:00', '2026-01-18 00:00:00');


insert into cm_user_entitlement_balances (id, user_id, membership_id, entitlement_code, period_started_at, period_ends_at, quota_total, quota_used, quota_remaining, created_at, updated_at) values
  ('ueb-001', 'u-001', 'user-membership-001', 'private_introduction', '2026-01-01 00:00:00', '2026-12-31 00:00:00', 15, 0, 15, '2026-01-18 00:00:00', '2026-01-18 00:00:00');


insert into cm_events (id, slug, status, visibility, city_code, address_visibility, event_date, start_time, end_time, capacity, cover_image_url, created_at, updated_at) values
  ('e-001', 'event-001', 'open', 'registered', 'paris', 'registered_only', '2026-05-12', '18:30', '21:00', 12, 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('e-002', 'event-002', 'waitlist', 'member', 'paris', 'confirmed_attendee_only', '2026-05-20', '19:00', '22:00', 8, 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('e-003', 'event-003', 'open', 'registered', 'brussels', 'registered_only', '2026-05-28', '14:30', '17:00', 16, 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80', '2026-04-01 00:00:00', '2026-05-01 00:00:00');


insert into cm_event_localized_fields (id, event_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('elf-00001', 'e-001', 'title', 'zh', '春季双语沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00002', 'e-001', 'title', 'fr', 'Salon bilingue du printemps', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00003', 'e-001', 'title', 'en', 'Spring bilingual salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00004', 'e-001', 'summary', 'zh', '围绕跨文化关系、工作节奏和城市生活展开小组交流。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00005', 'e-001', 'summary', 'fr', 'Echanges en petits groupes autour des relations interculturelles et du rythme de vie.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00006', 'e-001', 'summary', 'en', 'Small-group conversations around intercultural dating and lifestyle pace.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00007', 'e-001', 'city', 'zh', '巴黎', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00008', 'e-001', 'city', 'fr', 'Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00009', 'e-001', 'city', 'en', 'Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00010', 'e-001', 'venue', 'zh', '左岸私享沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00011', 'e-001', 'venue', 'fr', 'Salon prive rive gauche', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00012', 'e-001', 'venue', 'en', 'Left Bank private salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00013', 'e-001', 'address', 'zh', '巴黎第六区圣日耳曼大道 128 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00014', 'e-001', 'address', 'fr', '128 boulevard Saint-Germain, 75006 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00015', 'e-001', 'address', 'en', '128 Boulevard Saint-Germain, 75006 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00016', 'e-001', 'format', 'zh', '12人主题沙龙', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00017', 'e-001', 'format', 'fr', 'Salon thematique, 12 personnes', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00018', 'e-001', 'format', 'en', '12-person themed salon', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00019', 'e-001', 'audience', 'zh', '适合 27-35 岁、希望稳定发展的会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00020', 'e-001', 'audience', 'fr', 'Pour 27-35 ans avec intention relationnelle stable', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00021', 'e-001', 'audience', 'en', 'For members aged 27-35 seeking stable development', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00022', 'e-001', 'curator_note', 'zh', '策展人会在报名后确认资料完整度与参与节奏。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00023', 'e-001', 'curator_note', 'fr', 'Note du curateur : Le curateur confirme le dossier et le rythme apres la demande.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00024', 'e-001', 'curator_note', 'en', 'Curator note: A curator reviews profile readiness and pacing after submission.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00025', 'e-002', 'title', 'zh', '左岸晚餐局', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00026', 'e-002', 'title', 'fr', 'Diner rive gauche', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00027', 'e-002', 'title', 'en', 'Left Bank dinner gathering', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00028', 'e-002', 'summary', 'zh', '适合把线上兴趣转化为线下确认。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00029', 'e-002', 'summary', 'fr', 'Format intime pour valider une affinite observee en ligne.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00030', 'e-002', 'summary', 'en', 'An intimate format to validate affinity first seen online.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00031', 'e-002', 'city', 'zh', '巴黎', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00032', 'e-002', 'city', 'fr', 'Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00033', 'e-002', 'city', 'en', 'Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00034', 'e-002', 'venue', 'zh', '玛黑区私宴空间', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00035', 'e-002', 'venue', 'fr', 'Table privee au Marais', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00036', 'e-002', 'venue', 'en', 'Private dinner in Le Marais', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00037', 'e-002', 'address', 'zh', '巴黎玛黑区维埃耶杜唐普勒街 42 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00038', 'e-002', 'address', 'fr', '42 rue Vieille-du-Temple, 75004 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00039', 'e-002', 'address', 'en', '42 Rue Vieille-du-Temple, 75004 Paris', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00040', 'e-002', 'format', 'zh', '8人精选晚餐', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00041', 'e-002', 'format', 'fr', 'Diner selectif, 8 personnes', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00042', 'e-002', 'format', 'en', '8-person curated dinner', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00043', 'e-002', 'audience', 'zh', '主要面向已完成资料审核的会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00044', 'e-002', 'audience', 'fr', 'Principalement membres verifies', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00045', 'e-002', 'audience', 'en', 'Mainly for profile-verified members', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00046', 'e-002', 'curator_note', 'zh', '本场优先邀请已完成资料审核并适合晚餐节奏的会员。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00047', 'e-002', 'curator_note', 'fr', 'Priorite aux membres verifies et adaptes au format diner.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00048', 'e-002', 'curator_note', 'en', 'Priority is given to verified members suited to the dinner format.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00049', 'e-003', 'title', 'zh', '文化散步与咖啡交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00050', 'e-003', 'title', 'fr', 'Parcours culturel et cafe', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00051', 'e-003', 'title', 'en', 'Culture walk and coffee exchange', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00052', 'e-003', 'summary', 'zh', '以更轻松的方式开启第一次真实见面。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00053', 'e-003', 'summary', 'fr', 'Un format leger pour transformer le premier contact en rencontre reelle.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00054', 'e-003', 'summary', 'en', 'A lighter format for turning first contact into a real meeting.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00055', 'e-003', 'city', 'zh', '布鲁塞尔', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00056', 'e-003', 'city', 'fr', 'Bruxelles', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00057', 'e-003', 'city', 'en', 'Brussels', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00058', 'e-003', 'venue', 'zh', '欧洲区文化空间', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00059', 'e-003', 'venue', 'fr', 'Espace culturel du quartier europeen', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00060', 'e-003', 'venue', 'en', 'European Quarter cultural venue', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00061', 'e-003', 'address', 'zh', '布鲁塞尔欧洲区舒曼广场 6 号', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00062', 'e-003', 'address', 'fr', '6 rond-point Schuman, 1040 Bruxelles', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00063', 'e-003', 'address', 'en', '6 Schuman Roundabout, 1040 Brussels', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00064', 'e-003', 'format', 'zh', '城市散步 + 交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00065', 'e-003', 'format', 'fr', 'Balade urbaine + echanges', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00066', 'e-003', 'format', 'en', 'City walk plus discussion', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00067', 'e-003', 'audience', 'zh', '适合首次参加平台活动的新会员', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00068', 'e-003', 'audience', 'fr', 'Ideal pour une premiere participation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00069', 'e-003', 'audience', 'en', 'Good for first-time participants', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00070', 'e-003', 'curator_note', 'zh', '策展说明：适合第一次参加平台活动的会员，策展人会协助控制交流边界。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00071', 'e-003', 'curator_note', 'fr', 'Note du curateur : Format adapte a une premiere participation, avec cadrage du curateur.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('elf-00072', 'e-003', 'curator_note', 'en', 'Curator note: Good for first participation, with curator-guided boundaries.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');


insert into cm_event_relationship_focuses (id, event_id, focus_order, locale, value, source, provider, status, created_at, updated_at) values
  ('erf-00001', 'e-001', 0, 'zh', '跨文化关系', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00002', 'e-001', 0, 'fr', 'Relations interculturelles', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00003', 'e-001', 0, 'en', 'Intercultural relationship', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00004', 'e-001', 1, 'zh', '稳定发展', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00005', 'e-001', 1, 'fr', 'Relation stable', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00006', 'e-001', 1, 'en', 'Stable development', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00007', 'e-002', 0, 'zh', '线下确认', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00008', 'e-002', 0, 'fr', 'Validation hors ligne', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00009', 'e-002', 0, 'en', 'Offline confirmation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00010', 'e-002', 1, 'zh', '高质量晚餐局', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00011', 'e-002', 1, 'fr', 'Diner selectif', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00012', 'e-002', 1, 'en', 'Curated dinner', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00013', 'e-003', 0, 'zh', '首次见面', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00014', 'e-003', 0, 'fr', 'Premiere rencontre', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00015', 'e-003', 0, 'en', 'First meeting', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00016', 'e-003', 1, 'zh', '轻量交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00017', 'e-003', 1, 'fr', 'Echange leger', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('erf-00018', 'e-003', 1, 'en', 'Light conversation', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');


insert into cm_event_language_codes (event_id, language_code) values
  ('e-001', 'zh'),
  ('e-001', 'fr'),
  ('e-001', 'en'),
  ('e-002', 'zh'),
  ('e-002', 'fr'),
  ('e-002', 'en'),
  ('e-003', 'fr'),
  ('e-003', 'en');


insert into cm_event_agenda_items (id, event_id, agenda_time, sort_order, created_at, updated_at) values
  ('agenda-e-001-1', 'e-001', '18:30 - 19:00', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('agenda-e-001-2', 'e-001', '19:00 - 19:45', 2, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('agenda-e-002-1', 'e-002', '19:00 - 19:30', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00'),
  ('agenda-e-003-1', 'e-003', '14:30 - 15:00', 1, '2026-04-01 00:00:00', '2026-05-01 00:00:00');


insert into cm_event_agenda_item_localized_fields (id, agenda_item_id, field_name, locale, value, source, provider, status, created_at, updated_at) values
  ('ealf-00001', 'agenda-e-001-1', 'title', 'zh', '签到与活动说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00002', 'agenda-e-001-1', 'title', 'fr', 'Accueil et cadrage de l evenement', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00003', 'agenda-e-001-1', 'title', 'en', 'Check-in and event framing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00004', 'agenda-e-001-1', 'description', 'zh', '确认到场信息并说明当晚节奏。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00005', 'agenda-e-001-1', 'description', 'fr', 'Verification des arrivees et du rythme de la soiree.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00006', 'agenda-e-001-1', 'description', 'en', 'Arrival verification and evening pacing overview.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00007', 'agenda-e-001-2', 'title', 'zh', '主题小组交流', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00008', 'agenda-e-001-2', 'title', 'fr', 'Echanges thematiques', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00009', 'agenda-e-001-2', 'title', 'en', 'Themed small-group exchange', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00010', 'agenda-e-001-2', 'description', 'zh', '围绕关系、工作和城市生活展开交流。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00011', 'agenda-e-001-2', 'description', 'fr', 'Echanges autour des relations, du travail et de la vie urbaine.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00012', 'agenda-e-001-2', 'description', 'en', 'Conversation around relationships, work, and city life.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00013', 'agenda-e-002-1', 'title', 'zh', '入场与座位安排', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00014', 'agenda-e-002-1', 'title', 'fr', 'Accueil et placement', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00015', 'agenda-e-002-1', 'title', 'en', 'Arrival and seating', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00016', 'agenda-e-002-1', 'description', 'zh', '晚餐节奏与边界说明。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00017', 'agenda-e-002-1', 'description', 'fr', 'Rappel du cadre et du rythme du diner.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00018', 'agenda-e-002-1', 'description', 'en', 'Briefing on boundaries and dinner pacing.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00019', 'agenda-e-003-1', 'title', 'zh', '集合与路线说明', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00020', 'agenda-e-003-1', 'title', 'fr', 'Rassemblement et briefing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00021', 'agenda-e-003-1', 'title', 'en', 'Meet-up and route briefing', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00022', 'agenda-e-003-1', 'description', 'zh', '路线与交流节奏说明。', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00023', 'agenda-e-003-1', 'description', 'fr', 'Rappel du parcours et du rythme d echange.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20'),
  ('ealf-00024', 'agenda-e-003-1', 'description', 'en', 'Overview of the route and interaction rhythm.', 'manual', 'human', 'ready', '2026-04-01 00:00:00', '2026-05-18 12:07:20');


insert into cm_event_registrations (id, user_id, event_id, status, requested_at, confirmed_at, declined_at, waitlisted_at, cancelled_at, attended_at, created_at, updated_at) values
  ('er-001', 'u-001', 'e-001', 'cancelled', '2026-05-01 09:00:00', '2026-05-14 01:01:44', null, null, '2026-05-14 01:01:46', null, '2026-05-01 09:00:00', '2026-05-14 01:01:46'),
  ('er-002', 'u-001', 'e-002', 'cancelled', '2026-05-01 09:00:00', null, null, null, '2026-05-14 00:37:05', null, '2026-05-01 09:00:00', '2026-05-14 00:37:05'),
  ('er-003', 'u-001', 'e-003', 'cancelled', '2026-05-28 21:28:47', null, null, null, '2026-05-28 21:28:48', null, '2026-05-17 11:01:31', '2026-05-28 21:28:48');


insert into cm_favorite_profiles (id, user_id, profile_id, created_at, updated_at) values
  ('f-001', 'u-001', 'p-001', '2026-03-12 00:00:00', '2026-03-12 00:00:00'),
  ('f-002', 'u-001', 'p-006', '2026-03-28 00:00:00', '2026-03-28 00:00:00');


insert into cm_private_introduction_requests (id, requester_user_id, requester_profile_id, target_profile_id, status, message, requested_at, expires_at, responded_at, cooldown_until, entitlement_balance_id, created_at, updated_at) values
  ('intro-001', 'u-001', null, 'p-006', 'accepted', null, '2026-05-23 21:31:05', null, '2026-05-27 23:47:13', null, null, '2026-05-23 21:31:05', '2026-05-27 23:47:13');


insert into cm_inbox_threads (id, user_id, category, subject_type, subject_id, status, created_at, updated_at) values
  ('inbox-thread-001', 'u-001', 'system', 'profile', 'p-001', 'open', '2026-05-20 09:00:00', '2026-05-28 08:30:00'),
  ('inbox-thread-003', 'u-001', 'system', null, null, 'open', '2026-05-28 06:00:00', '2026-05-28 06:00:00'),
  ('inbox-thread-002', 'u-001', 'system', 'event', 'e-001', 'open', '2026-05-25 14:00:00', '2026-05-27 10:00:00');


insert into cm_inbox_messages (id, thread_id, sender_type, sender_user_id, message_type, body, template_code, template_locale, action_type, action_payload, created_at, updated_at) values
  ('msg-001', 'inbox-thread-001', 'system', null, 'system_notice', '你的资料 p-001 平台审核已通过，现状态变更为 open。', 'profile_review_approved', 'zh', null, null, '2026-05-20 09:00:00', '2026-05-20 09:00:00'),
  ('msg-002', 'inbox-thread-001', 'system', null, 'text', '你的资料已完成身份认证，可信度已提升。', 'identity_verified', 'zh', null, null, '2026-05-28 08:30:00', '2026-05-28 08:30:00'),
  ('msg-003', 'inbox-thread-002', 'system', null, 'system_notice', '你报名的活动《巴黎春季交流酒会》报名已确认。', 'event_registration_confirmed', 'zh', null, null, '2026-05-25 14:00:00', '2026-05-25 14:00:00'),
  ('msg-004', 'inbox-thread-002', 'system', null, 'text', '活动地址：巴黎 8 区 Rue du Faubourg Saint-Honore 25 号。请提前 15 分钟到场。', 'event_reminder', 'zh', null, null, '2026-05-27 10:00:00', '2026-05-27 10:00:00'),
  ('msg-005', 'inbox-thread-003', 'system', null, 'text', '欢迎使用相约巴黎！你可以创建资料、浏览活动、收藏感兴趣的会员。', 'welcome_message', 'zh', null, null, '2026-05-28 06:00:00', '2026-05-28 06:00:00');


insert into cm_inbox_reads (id, thread_id, user_id, last_read_at, created_at, updated_at) values
  ('read-001', 'inbox-thread-003', 'u-001', '2026-05-28 07:00:00', '2026-05-28 07:00:00', '2026-05-28 07:00:00'),
  ('read-002', 'inbox-thread-001', 'u-001', '2026-05-28 00:13:32', '2026-05-28 00:13:32', '2026-05-28 00:13:32');

