import { NextResponse } from 'next/server';
import nodemailer from 'nodemailer';

export async function POST(req: Request) {
  try {
    const { name, email, phone, message } = await req.json();

    // Log the configuration check (without revealing passwords)
    console.log("Configuration SMTP Hostinger:", {
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      user: process.env.SMTP_USER,
    });

    if (!process.env.SMTP_HOST || !process.env.SMTP_USER || !process.env.SMTP_PASS) {
      console.error("Identifiants SMTP manquants dans l'environnement (.env)");
      return NextResponse.json(
        { error: "Configuration email du serveur manquante." },
        { status: 500 }
      );
    }

    // Configurer le transporteur SMTP Hostinger
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: Number(process.env.SMTP_PORT) || 465, // Souvent 465 pour SSL ou 587 pour TLS
      secure: true, // true for 465, false for other ports
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    // Optionnel : Vous pouvez vérifier la connexion SMTP
    // await transporter.verify();

    // Définir le contenu de l'email
    const mailOptions = {
      from: `"${name}" <${process.env.SMTP_USER}>`, // Toujours utiliser l'adresse authentifiée comme expéditeur technique pour éviter les blocages spam
      replyTo: email, // L'adresse de l'utilisateur pour pouvoir lui répondre
      to: "yvette.mengue@guezs-house.com",
      subject: `NOUVEAU CONTACT WEB: ${name}`,
      text: `Vous avez reçu un nouveau message depuis le formulaire de contact du site (Modale d'en-tête).\n\nNom: ${name}\nTéléphone: ${phone}\nEmail: ${email}\n\nMessage:\n${message}`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
          <h2 style="color: #D4AF37;">Nouveau message de contact</h2>
          <p>Vous avez reçu une nouvelle demande depuis le formulaire de contact du site GUEZS HOUSE.</p>
          <table style="width: 100%; max-width: 600px; border-collapse: collapse; margin-top: 20px;">
            <tr>
              <td style="padding: 10px; border-bottom: 1px solid #eee; width: 120px;"><strong>Nom :</strong></td>
              <td style="padding: 10px; border-bottom: 1px solid #eee;">${name}</td>
            </tr>
            <tr>
              <td style="padding: 10px; border-bottom: 1px solid #eee;"><strong>Téléphone :</strong></td>
              <td style="padding: 10px; border-bottom: 1px solid #eee;">${phone}</td>
            </tr>
            <tr>
              <td style="padding: 10px; border-bottom: 1px solid #eee;"><strong>Email :</strong></td>
              <td style="padding: 10px; border-bottom: 1px solid #eee;">
                <a href="mailto:${email}" style="color: #D4AF37;">${email}</a>
              </td>
            </tr>
          </table>
          <div style="margin-top: 20px; padding: 15px; background-color: #f9f9f9; border-left: 4px solid #D4AF37;">
            <p style="margin-top: 0;"><strong>Message :</strong></p>
            <p style="white-space: pre-wrap;">${message}</p>
          </div>
        </div>
      `,
    };

    // Envoyer l'email
    await transporter.sendMail(mailOptions);

    return NextResponse.json(
      { message: "Email envoyé avec succès." },
      { status: 200 }
    );
  } catch (error: any) {
    console.error("Erreur détaillée lors de l'envoi de l'email:", error);
    return NextResponse.json(
      { error: "Erreur lors de l'envoi du message.", details: error.message },
      { status: 500 }
    );
  }
}
