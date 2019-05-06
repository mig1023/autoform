# autoform

### Appointment system for CRM with:

| N | Сharacteristic |
| ------------- | ------------- |
| 1 | multistage checks, with autogeneration js-checks |
| 2 | automatic replacement of unprintable characters |
| 3 | checking the logic of the relation of various fields |
| 4 | microORM integrated |
| 5 | flexible structure, based on hash-data |
| 6 | examples & detailed comments for each field |
| 7 | mobile version integrated |
| 8 | etc... |


### Field data example:
```
{
  type => 'input',
  name => 'email',
  label => 'Email',
  comment => 'Введите существующий адрес почты.',
  example => 'mail@example.com',
  check => 'zWN\@\-\_\.',
  check_logic => [
    {
      condition => 'this_is_email',
    },
    {
      condition => 'email_not_blocked',
    },
  ],
  db => {
    table => 'Appointments',
    name => 'EMail',
  },
},
```
### Screenshot:
<p align="center">
<img src="https://s8.hostingkartinok.com/uploads/images/2017/11/caeae3bc4e1937ca4c7596107eef5725.png">
</p>
