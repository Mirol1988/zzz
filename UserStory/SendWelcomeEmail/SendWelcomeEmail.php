<?php

declare(strict_types=1);

namespace app\UserStory\SendWelcomeEmail;

use Yii;

class SendWelcomeEmail
{
    public function __construct(
        private string $email
    )
    {
    }

    public function send()
    {
        Yii::$app->mailer->compose()
            ->setFrom('from@domain.com')
            ->setTo($this->email)
            ->setSubject('Добро пожаловать к нам на пример')
            ->setTextBody('Добро пожаловать к нам на пример')
            ->setHtmlBody('<b>Добро пожаловать к нам на пример</b>')
            ->send();
    }
}