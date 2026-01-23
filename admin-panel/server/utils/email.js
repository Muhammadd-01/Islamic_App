import nodemailer from 'nodemailer';

/**
 * Send an email to the user regarding their order
 * @param {Object} options - Email options
 * @param {string} options.to - User's email
 * @param {string} options.orderId - The order ID
 * @param {string} options.status - The new status
 * @param {Object} options.orderData - Full order detail
 */
export const sendOrderEmail = async ({ to, orderId, status, orderData }) => {
    // Check for SMTP config
    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
        console.warn('SMTP credentials missing. Email not sent.');
        return;
    }

    const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST || 'smtp.gmail.com',
        port: process.env.SMTP_PORT || 587,
        secure: false, // true for 465, false for other ports
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
        },
    });

    const statusColors = {
        pending: '#f39c12',
        proceed: '#3498db',
        completed: '#27ae60',
        cancelled: '#c0392b',
        processing: '#2980b9'
    };

    const color = statusColors[status] || '#2c3e50';

    const html = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 10px; padding: 20px;">
            <div style="text-align: center; margin-bottom: 20px;">
                <h1 style="color: #2c3e50;">Order Update</h1>
            </div>
            <p>Assalamu Alaikum,</p>
            <p>Your order status has been updated.</p>
            
            <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
                <p><strong>Order ID:</strong> #${orderId}</p>
                <p><strong>Status:</strong> <span style="color: ${color}; font-weight: bold; text-transform: uppercase;">${status}</span></p>
                <p><strong>Total Amount:</strong> $${orderData.total || 0}</p>
            </div>

            <h3>Order Items:</h3>
            <ul>
                ${orderData.items.map(item => `
                    <li>${item.name || item.title} (x${item.quantity || 1}) - $${item.price}</li>
                `).join('')}
            </ul>

            <div style="margin-top: 30px; border-top: 1px solid #eee; padding-top: 20px; text-align: center; font-size: 12px; color: #7f8c8d;">
                <p>Thank you for shopping with DeenSphere.</p>
                <p>If you have any questions, please contact our support.</p>
            </div>
        </div>
    `;

    try {
        await transporter.sendMail({
            from: `"DeenSphere" <${process.env.SMTP_USER}>`,
            to,
            subject: `Order Update: #${orderId} is now ${status}`,
            html,
        });
        console.log(`Email sent successfully to ${to}`);
    } catch (error) {
        console.error('Error sending email:', error);
    }
};
