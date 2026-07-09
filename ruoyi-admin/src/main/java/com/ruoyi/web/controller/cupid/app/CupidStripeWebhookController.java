package com.ruoyi.web.controller.cupid.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.cupid.service.ICupidPaymentService;

@RestController
@RequestMapping("/api/payment/stripe")
public class CupidStripeWebhookController
{
    @Autowired
    private ICupidPaymentService paymentService;

    @PostMapping("/webhook")
    public ResponseEntity<String> webhook(@RequestBody String payload,
            @RequestHeader("Stripe-Signature") String signature)
    {
        paymentService.handleStripeWebhook(payload, signature);
        return ResponseEntity.ok("ok");
    }
}
