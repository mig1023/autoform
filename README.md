# autoform

### Appointment system for CRM with:

| N | Сharacteristic |
| ------------- | ------------- |
| 1 | multistage checks, with autogeneration js-checks |
| 2 | many types of fields: input, checkbox, radio, checkbox group, etc |
| 3 | automatic replacement of unprintable characters |
| 4 | checking the logic of the relation of various fields |
| 5 | microORM integrated |
| 6 | flexible structure, based on hash-data |
| 7 | examples & detailed comments for each field |
| 8 | mobile version integrated |
| 9 | etc... |


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
